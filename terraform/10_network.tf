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
}
# Define the AKS network security group (NSG)
module "aks_nsg" {
  source              = "../modules/nsg"
  name                = "${var.aks_config.name}-nsg"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
}


################################################################
# Framed Change In Progress.... INCOMPLETE!!!
################################################################
# Need to expand every: or_each = var.aks_config.subnets_map 
# for:
# - node_pool_map["aks_default_node_pool"].node_address_prefixes
# - node_pool_map["aks_default_node_pool"].pod_address_prefixes
# - node_pool_map["aks_user_node_pool_*"].node_address_prefixes
# - node_pool_map["aks_user_node_pool_*"].pod_address_prefixes
# module "subnets_nsg_association" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.subnets_map
#   subnets_map               = var.aks_config.subnets_map
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
module "subnets_nsg_association_default_node_pool" {
  source                    = "../modules/nsga"
  for_each                  = node_pool_map["aks_default_node_pool"].node_address_prefixes
  subnets_map               = node_pool_map["aks_default_node_pool"].node_address_prefixes
  subnet_id                 = module.aks_subnets.subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
module "subnets_nsg_association_default_pod_pool" {
  source                    = "../modules/nsga"
  for_each                  = node_pool_map["aks_default_node_pool"].pod_address_prefixes
  subnets_map               = node_pool_map["aks_default_node_pool"].pod_address_prefixes
  subnet_id                 = module.aks_subnets.subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
module "subnets_nsg_association_node_pools" {
  source                    = "../modules/nsga"
  for_each                  = node_pool_map["aks_user_node_pool_*"].node_address_prefixes     # <=== PSEUDO CODE!!!!
  subnets_map               = node_pool_map["aks_user_node_pool_*"].node_address_prefixes     # <=== PSEUDO CODE!!!!
  subnet_id                 = module.aks_subnets.subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
module "subnets_nsg_association_pod_pools" {
  source                    = "../modules/nsga"
  for_each                  = node_pool_map["aks_user_node_pool_*"].pod_address_prefixes     # <=== PSEUDO CODE!!!!
  subnets_map               = node_pool_map["aks_user_node_pool_*"].pod_address_prefixes     # <=== PSEUDO CODE!!!!
  subnet_id                 = module.aks_subnets.subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
################################################################
################################################################

# Define NSG rules
module "allow_pod_subnet_outbound" {
  source                      = "../modules/nsr"
  subnets_map                 = var.aks_config.subnets_map
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
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_2"].address_prefixes
  )
  destination_address_prefixes = ["0.0.0.0/0"]
}
module "allow_pod_to_pod" {
  source                      = "../modules/nsr"
  subnets_map                 = var.aks_config.subnets_map
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
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_2"].address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_2"].address_prefixes
  ) 
}
module "deny_node_to_pod_subnet" {
  source                      = "../modules/nsr"
  subnets_map                 = var.aks_config.subnets_map
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
    var.aks_config.node_pool_map.node_address_prefixes["aks_node_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_node_subnet_2"].address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_2"].address_prefixes
  )
}
module "deny_pod_to_node_subnet" {
  source                      = "../modules/nsr"
  subnets_map                 = var.aks_config.subnets_map
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
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_2"].address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.node_pool_map.node_address_prefixes["aks_node_subnet_1"].address_prefixes,
    var.aks_config.node_pool_map.node_address_prefixes["aks_node_subnet_2"].address_prefixes
  )
}
