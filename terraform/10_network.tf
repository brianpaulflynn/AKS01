# Define the virtual network and subnets for AKS
module "aks_vnet" {
  source              = "../modules/vnet"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
module "aks_subnets" {
  source               = "../modules/subnet"
  resource_group_name  = module.aks_cluster_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
  node_pool_map        = var.aks_config.node_pool_map
}
# Define the AKS network security group (NSG)
module "aks_nsg" {
  source              = "../modules/nsg"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = "${var.aks_config.name}-nsg"
}
# Define the NSG associations for each subnet
module "subnets_nsg_associations_nodes" {
  source                    = "../modules/nsga"
  for_each                  = module.aks_subnets.aks_node_subnet_ids
  subnet_id                 = module.aks_subnets.aks_node_subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
module "subnets_nsg_associations_pods" {
  source                    = "../modules/nsga"
  for_each                  = module.aks_subnets.aks_pod_subnet_ids
  subnet_id                 = module.aks_subnets.aks_pod_subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
# Define the network security rules
module "allow_pod_subnet_outbound" {
  source                      = "../modules/nsr"
  name                        = "pod-subnet-outbound"
  resource_group_name         = module.aks_cluster_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
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
  source                      = "../modules/nsr"
  name                        = "pod-to-pod-inbound"
  resource_group_name         = module.aks_cluster_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
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
  source                      = "../modules/nsr"
  name                        = "deny-node-to-pod-subnet"
  resource_group_name         = module.aks_cluster_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
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
  source = "../modules/nsr"
  #node_pool_map               = module.aks_subnets.aks_config.node_pool_map
  name                        = "deny-pod-to-node-subnet"
  resource_group_name         = module.aks_cluster_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
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
