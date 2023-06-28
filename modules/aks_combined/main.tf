#RG
module "aks_rg" {
  source   = "../rg"
  location = var.aks_config.location
  name     = var.aks_config.rg
}
#VNET
module "aks_vnet" {
  source              = "../vnet"
  resource_group_name = module.aks_rg.rg_name
  location            = module.aks_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
#SUBNETS
######## TODO: work this in to replace the 2 resources below.
# module "aks_subnets" {
#   source               = "../modules/aks_subnet"
#   resource_group_name  = module.aks_rg.rg_name
#   virtual_network_name = module.aks_vnet.vnet_name
#   node_pool_map        = var.aks_config.node_pool_map
# }
resource "azurerm_subnet" "aks_node_subnets" {
  resource_group_name  = module.aks_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
  for_each             = var.aks_config.node_pool_map
  name                 = "${each.key}_nodes"              # <=== NODES!
  address_prefixes     = each.value.node_address_prefixes # <=== NODES!
  dynamic "delegation" {                                  # Grant cluster access to manage subnets
    for_each = each.key != "aks_default_pool" ? [each.key] : []
    content { # rem no delegation for default node pool
      name = "${each.key}_delegation"
      service_delegation {
        name    = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/networkinterfaces/*"]
      }
    }
  }
}
resource "azurerm_subnet" "aks_pod_subnets" {
  for_each             = var.aks_config.node_pool_map
  resource_group_name  = module.aks_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
  name                 = "${each.key}_pods"              # <=== PODS!
  address_prefixes     = each.value.pod_address_prefixes # <=== PODS!
  dynamic "delegation" {                                 # Grant cluster access to manage subnets
    for_each = each.key != "aks_default_pool" ? [each.key] : []
    content { # rem no delegation for default node pool
      name = "${each.key}_delegation"
      service_delegation {
        name    = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/networkinterfaces/*"]
      }
    }
  }
}
##############################################################################
#NSG
module "aks_cluster_nsg" {
  source              = "../nsg"
  resource_group_name = module.aks_rg.rg_name
  location            = module.aks_rg.rg_location
  name                = "${var.aks_config.name}-nsg"
}
#NSGAs
module "aks_subnets_nsg_associations" {
  source                    = "../nsga"
  network_security_group_id = module.aks_cluster_nsg.network_security_group_id
  for_each = {
    for subnet_name, subnet
    in merge(azurerm_subnet.aks_node_subnets,
      azurerm_subnet.aks_pod_subnets
    )
    : subnet_name => subnet.id
  }
  subnet_id = each.value
}
#NSGR
module "allow_pod_subnet_outbound" {
  source                      = "../nsr"
  resource_group_name         = module.aks_rg.rg_name
  network_security_group_name = module.aks_cluster_nsg.network_security_group_name
  name                        = "allow-pod-subnet-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
  )
  destination_address_prefixes = ["0.0.0.0/0"]
}
module "allow_pod_to_pod" {
  source                      = "../nsr"
  resource_group_name         = module.aks_rg.rg_name
  network_security_group_name = module.aks_cluster_nsg.network_security_group_name
  name                        = "allow-pod-to-pod-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
  )
}
module "deny_node_to_pod_subnet" {
  source                      = "../nsr"
  resource_group_name         = module.aks_rg.rg_name
  network_security_group_name = module.aks_cluster_nsg.network_security_group_name
  name                        = "deny-node-to-pod-subnet"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].node_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].node_address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
  )
}
module "deny_pod_to_node_subnet" {
  source                      = "../nsr"
  resource_group_name         = module.aks_rg.rg_name
  network_security_group_name = module.aks_cluster_nsg.network_security_group_name
  name                        = "deny-pod-to-node-subnet"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.node_pool_map["aks_user_pool_1"].node_address_prefixes,
    var.aks_config.node_pool_map["aks_user_pool_2"].node_address_prefixes
  )
}
# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  resource_group_name       = module.aks_rg.rg_name
  location                  = module.aks_rg.rg_location
  azure_policy_enabled      = true # Best Practice
  open_service_mesh_enabled = true # Best Practice
  local_account_disabled    = true # Best Practice. And required by AAD integration.
  #role_based_access_control_enabled = true          # does this conflict with azure_rbac_enabled?
  azure_active_directory_role_based_access_control { # AAD interated
    azure_rbac_enabled     = true                    # with RBAC permissions granularity
    managed                = true                    # managed by AD Group
    admin_group_object_ids = [var.AD_GROUP_ID]       # from TF_VARS
  }                                                  # for some AAD group identifier
  identity {                                         # Managed Identity
    type         = "UserAssigned"
    identity_ids = var.aks_managed_identity_ids
  }
  oms_agent { # Container Insights
    msi_auth_for_monitoring_enabled = true
    log_analytics_workspace_id      = var.aks_log_analytics_workspace_id
  }
  microsoft_defender { # Defender
    log_analytics_workspace_id = var.aks_log_analytics_workspace_id
  }
  network_profile {          # CNI Networking
    network_plugin = "azure" # ...
    network_policy = "azure" # Not Calico
    outbound_type  = var.aks_config.loadBalancer_type
    service_cidr   = var.aks_config.service_cidr
    dns_service_ip = var.aks_config.service_dns
  }
  name                          = var.aks_config.name
  node_resource_group           = var.aks_config.nodes_rg
  dns_prefix                    = var.aks_config.dns_prefix
  run_command_enabled           = var.aks_config.run_command_enabled
  public_network_access_enabled = var.aks_config.public_network_access_enabled
  private_cluster_enabled       = var.aks_config.private_cluster_enabled
  default_node_pool {
    zones                        = var.aks_config.node_pool_map["aks_default_pool"].zones
    vm_size                      = var.aks_config.node_pool_map["aks_default_pool"].vm_size
    name                         = var.aks_config.node_pool_map["aks_default_pool"].name
    os_disk_size_gb              = var.aks_config.node_pool_map["aks_default_pool"].os_disk_size_gb
    min_count                    = var.aks_config.node_pool_map["aks_default_pool"].min_count
    max_count                    = var.aks_config.node_pool_map["aks_default_pool"].max_count
    max_pods                     = var.aks_config.node_pool_map["aks_default_pool"].max_pods
    vnet_subnet_id               = azurerm_subnet.aks_node_subnets["aks_default_pool"].id
    pod_subnet_id                = azurerm_subnet.aks_pod_subnets["aks_default_pool"].id
    only_critical_addons_enabled = true
    enable_auto_scaling          = true
  }
}
#Define User Pools
resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  for_each = {
    for k, v
    in var.aks_config.node_pool_map : k => v
    if k != "aks_default_pool" # excdlude default pool. It is created w/ cluster.
  }
  vnet_subnet_id      = azurerm_subnet.aks_node_subnets[each.key].id
  pod_subnet_id       = azurerm_subnet.aks_pod_subnets[each.key].id
  enable_auto_scaling = var.aks_config.node_pool_map[each.key].enable_auto_scaling
  name                = var.aks_config.node_pool_map[each.key].name
  vm_size             = var.aks_config.node_pool_map[each.key].vm_size
  os_disk_size_gb     = var.aks_config.node_pool_map[each.key].os_disk_size_gb
  zones               = var.aks_config.node_pool_map[each.key].zones
  min_count           = var.aks_config.node_pool_map[each.key].min_count
  max_count           = var.aks_config.node_pool_map[each.key].max_count
  max_pods            = var.aks_config.node_pool_map[each.key].max_pods
  tags = {
    Environment = var.aks_config.node_pool_map[each.key].Environment
  }
}