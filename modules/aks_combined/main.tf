#AKS Resource Group
module "aks_rg" {
  source   = "../rg"
  location = var.aks_config.location
  name     = var.aks_config.rg
}
#AKS Virtual Network
module "aks_vnet" {
  source              = "../vnet"
  resource_group_name = module.aks_rg.rg_name
  location            = module.aks_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
#AKS Subnets
module "aks_subnets" {
  source               = "../aks_subnet"
  resource_group_name  = module.aks_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
  node_pool_map        = var.aks_config.node_pool_map
}
#AKS Network Security Group
module "aks_cluster_nsg" {
  source              = "../nsg"
  resource_group_name = module.aks_rg.rg_name
  location            = module.aks_rg.rg_location
  name                = "${var.aks_config.name}-nsg"
}
#AKS Network Security Group Associations
module "aks_subnets_nsg_associations" {
  source                    = "../nsga"
  network_security_group_id = module.aks_cluster_nsg.network_security_group_id
  for_each = merge(
    module.aks_subnets.aks_node_subnet_ids,
    module.aks_subnets.aks_pod_subnet_ids
  )
  subnet_id = each.value
}
#AKS Network Security Group Rules
module "aks_nsrs" {
  source                      = "../aks_nsrs"
  resource_group_name         = module.aks_rg.rg_name
  network_security_group_name = module.aks_cluster_nsg.network_security_group_name
  node_subnet_prefixes        = module.aks_subnets.aks_node_address_prefixes
  pod_subnet_prefixes         = module.aks_subnets.aks_pod_address_prefixes
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
    vnet_subnet_id               = module.aks_subnets.aks_node_subnet_ids["aks_default_pool"]
    pod_subnet_id                = module.aks_subnets.aks_pod_subnet_ids["aks_default_pool"]
    enable_auto_scaling          = true
    only_critical_addons_enabled = true
  }
}
#Define User Pools
resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  for_each = {
    for k, v
    in var.aks_config.node_pool_map : k => v
    if k != "aks_default_pool" # excdlude default pool; because
  }                            # it is created w/ cluster.
  zones               = var.aks_config.node_pool_map[each.key].zones
  vm_size             = var.aks_config.node_pool_map[each.key].vm_size
  name                = var.aks_config.node_pool_map[each.key].name
  os_disk_size_gb     = var.aks_config.node_pool_map[each.key].os_disk_size_gb
  min_count           = var.aks_config.node_pool_map[each.key].min_count
  max_count           = var.aks_config.node_pool_map[each.key].max_count
  max_pods            = var.aks_config.node_pool_map[each.key].max_pods
  enable_auto_scaling = var.aks_config.node_pool_map[each.key].enable_auto_scaling
  vnet_subnet_id      = module.aks_subnets.aks_node_subnet_ids[each.key]
  pod_subnet_id       = module.aks_subnets.aks_pod_subnet_ids[each.key]
  tags = {
    Environment = var.aks_config.node_pool_map[each.key].Environment
  }
}
