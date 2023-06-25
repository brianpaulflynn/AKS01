# Define the virtual network and subnets for AKS
module "aks_vnet" {
  source              = "../modules/vnet"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
module "aks_subnets" {
  source                = "../modules/subnet"
  resource_group_name   = module.aks_cluster_rg.rg_name
  virtual_network_name  = module.aks_vnet.vnet_name
  node_pool_map         = var.aks_config.node_pool_map
}
# Define the AKS network security group (NSG)
module "aks_nsg" {
  source              = "../modules/nsg"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = "${var.aks_config.name}-nsg"
}
# Define NSG rules
# module "nsg_rules" {
#   source                      = "../modules/nsr"
#   resource_group_name         = module.aks_cluster_rg.rg_name
#   network_security_group_name = module.aks_nsg.network_security_group_name
#   node_pool_map               = var.aks_config.node_pool_map
# }
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
  source_address_prefixes     = concat( 
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
  source_address_prefixes =     concat( 
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
  source_address_prefixes     = concat( 
                                    var.aks_config.node_pool_map["aks_user_pool_1"].node_address_prefixes,
                                    var.aks_config.node_pool_map["aks_user_pool_2"].node_address_prefixes
                                )  
  destination_address_prefixes = concat( 
                                    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
                                    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
                                ) 
}
module "deny_pod_to_node_subnet" {
  source                      = "../modules/nsr"
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
  source_address_prefixes =   concat( 
                                    var.aks_config.node_pool_map["aks_user_pool_1"].pod_address_prefixes,
                                    var.aks_config.node_pool_map["aks_user_pool_2"].pod_address_prefixes
                                ) 
  destination_address_prefixes = concat( 
                                    var.aks_config.node_pool_map["aks_user_pool_1"].node_address_prefixes,
                                    var.aks_config.node_pool_map["aks_user_pool_2"].node_address_prefixes
                                ) 
}



# Need to expand every: or_each = var.aks_config.subnets_map 
# for:
# - node_pool_map["aks_default_pool"].node_address_prefixes
# - node_pool_map["aks_default_pool"].pod_address_prefixes
# - node_pool_map["aks_user_node_pool_*"].node_address_prefixes
# - node_pool_map["aks_user_node_pool_*"].pod_address_prefixes

# module "subnets_nsg_association_nodes" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map
#   #node_pool_map             = var.aks_config.node_pool_map
#   #NODES SUBNET IDS!
#   subnet_id                 = module.aks_subnets.aks_node_subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_pods" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map
#   subnet_id                 = module.aks_subnets.aks_pod_subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }

# module "subnets_nsg_associations" {
#   source                    = "../modules/nsga"
#   for_each                  = 
#                               #var.aks_config.subnets_map
#   # subnets_map               = var.aks_config.subnets_map
#   subnet_id                 = module.aks_subnets.aks_node_subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
#   # resource_group_name         = module.aks_cluster_rg.rg_name
#   # network_security_group_name = module.aks_nsg.network_security_group_name
# }

# module "subnets_nsg_association" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.subnets_map
#   subnets_map               = var.aks_config.subnets_map
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_default_node_pool_node_address_prefixes" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map
#   subnets_map               = var.aks_config.node_pool_map
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key] #### 
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_default_node_pool_pod_address_prefixes" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map
#   subnets_map               = var.aks_config.node_pool_map
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key] #### 
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_default_node_pool" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map["aks_default_pool"].node_address_prefixes
#   subnets_map               = var.aks_config.node_pool_map["aks_default_pool"].node_address_prefixes
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key] #### 
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_default_pod_pool" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map["aks_default_pool"].pod_address_prefixes
#   subnets_map               = var.aks_config.node_pool_map["aks_default_pool"].pod_address_prefixes
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_node_pools" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map["aks_user_node_pool_*"].node_address_prefixes     # <=== PSEUDO CODE!!!!
#   subnets_map               = var.aks_config.node_pool_map["aks_user_node_pool_*"].node_address_prefixes     # <=== PSEUDO CODE!!!!
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# module "subnets_nsg_association_pod_pools" {
#   source                    = "../modules/nsga"
#   for_each                  = var.aks_config.node_pool_map["aks_user_node_pool_*"].pod_address_prefixes     # <=== PSEUDO CODE!!!!
#   subnets_map               = var.aks_config.node_pool_map["aks_user_node_pool_*"].pod_address_prefixes     # <=== PSEUDO CODE!!!!
#   subnet_id                 = module.aks_subnets.subnet_ids[each.key]
#   network_security_group_id = module.aks_nsg.network_security_group_id
# }
# ################################################################
# ################################################################




# Define NSG rules

# resource "azurerm_network_security_rule" "example" {
#   name                        = "example-rule"
#   resource_group_name         = azurerm_resource_group.example.name
#   network_security_group_name = azurerm_network_security_group.example.name
#   destination_address_prefix  = "0.0.0.0/0"
#   direction                   = "Outbound"
#   access                      = "Allow"
#   priority                    = 100
# }
/*
module "allow_pod_subnet_outbound" {
  source                      = "../modules/nsr"
  #node_pool_map               = var.aks_config.node_pool_map
  name                        = "pod-subnet-outbound"
  resource_group_name         = module.aks_cluster_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  #for_each = each.key != "aks_default_pool" ? ["${each.key}_delegation"] : []
  #for_each = { for k, v in module.aks_subnets : regex(".*_nodes$", k) => v }
  #for_each = { for k, v in module.aks_subnets : regex(".*_pods$", k) => v }
  dynamic "source_address_prefixes" {
    for_each = {
      for subnet in azurerm_subnet.example :
      subnet.name => subnet
      if substr(subnet.name, length(subnet.name) - 3) == "_pod"
    }

    content {
      address_prefixes = source_address_prefixes.value.pod_address_prefixes
    }
  }
  # source_address_prefixes = concat(


  #   module.aks_subnets["aks_pod_subnets"]
  #   .address_prefixes,
  #   module.aks_subnets["aks_pod_subnets"].address_prefixes


  # )
  destination_address_prefixes = ["0.0.0.0/0"]
}

module "allow_pod_to_pod" {
  source                      = "../modules/nsr"
  #node_pool_map               = var.aks_config.node_pool_map
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
    module.aks_subnets["aks_pod_subnets"].address_prefixes
  )
  destination_address_prefixes = concat(
    module.aks_subnets["aks_pod_subnets"].address_prefixes
  ) 
}



module "deny_node_to_pod_subnet" {
  source                      = "../modules/nsr"
  #node_pool_map               = module.aks_subnets.aks_config.node_pool_map
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
    module.aks_subnets["aks_node_subnets"].address_prefixes
  )
  destination_address_prefixes = concat(
    module.aks_subnets["aks_pod_subnets"].address_prefixes
  )
}
module "deny_pod_to_node_subnet" {
  source                      = "../modules/nsr"
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
    module.aks_subnets["aks_pod_subnets"].address_prefixes
  )
  destination_address_prefixes = concat(
    module.aks_subnets["aks_node_subnets"].address_prefixes
  )
}
*/