# Define the AKS network security group (NSG)
resource "azurerm_network_security_group" "aks_cluster_nsg" {
  name                          = "${var.aks_config.name}-nsg"
  resource_group_name           = azurerm_resource_group.aks_cluster_rg.name
  location                      = azurerm_resource_group.aks_cluster_rg.location
}
resource "azurerm_subnet_network_security_group_association" "subnets_nsg_association" {
  for_each                      = var.aks_config.subnets_map
  subnet_id                     = module.aks_subnets.subnet_ids[each.key]
  network_security_group_id     = azurerm_network_security_group.aks_cluster_nsg.id
}
# Define NSG rules
resource "azurerm_network_security_rule" "allow_pod_subnet_outbound" {
  name                          = "pod-subnet-outbound"
  resource_group_name           = azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name   = azurerm_network_security_group.aks_cluster_nsg.name
  priority                      = 100
  direction                     = "Outbound"
  access                        = "Allow"
  protocol                      = "*"
  source_port_range             = "*"
  destination_port_range        = "*"
  source_address_prefixes       = concat( 
                                    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
                                ) #["10.0.128.0/17"]
  destination_address_prefixes  = ["0.0.0.0/0"]
}
resource "azurerm_network_security_rule" "allow_pod_to_pod" {
  name                          = "pod-to-pod-inbound"
  resource_group_name           = azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name   = azurerm_network_security_group.aks_cluster_nsg.name
  priority                      = 100
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "*"
  source_port_range             = "*"
  destination_port_range        = "*"
  source_address_prefixes       = concat( 
                                    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
                                )
  destination_address_prefixes  = concat (  
                                    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
                                ) # ["10.0.128.0/17"]
}
resource "azurerm_network_security_rule" "deny_node_to_pod_subnet" {
  name                          = "deny-node-to-pod-subnet"
  resource_group_name           = azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name   = azurerm_network_security_group.aks_cluster_nsg.name
  priority                      = 101
  direction                     = "Inbound"
  access                        = "Deny"
  protocol                      = "*"
  source_port_range             = "*"
  destination_port_range        = "*"
  source_address_prefixes       = concat( 
                                    var.aks_config.subnets_map["aks_node_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_node_subnet_2"].address_prefixes
                                ) # ["10.0.120.0/21"]
  destination_address_prefixes  = concat( 
                                    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
                                ) # ["10.0.128.0/17"]
}
resource "azurerm_network_security_rule" "deny_pod_to_node_subnet" {
  name                          = "deny-pod-to-node-subnet"
  resource_group_name           = azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name   = azurerm_network_security_group.aks_cluster_nsg.name
  priority                      = 102
  direction                     = "Inbound"
  access                        = "Deny"
  protocol                      = "*"
  source_port_range             = "*"
  destination_port_range        = "*"
  source_address_prefixes       = concat( 
                                    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
                                ) # ["10.0.128.0/17"]
  destination_address_prefixes  = concat( 
                                    var.aks_config.subnets_map["aks_node_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_node_subnet_2"].address_prefixes
                                ) # ["10.0.120.0/21"]
}
# resource "azurerm_network_security_rule" "deny_node_subnet_egress" {
#   name                          = "deny-node-subnet-egress"
#   resource_group_name           = azurerm_resource_group.aks_cluster_rg.name
#   network_security_group_name   = azurerm_network_security_group.aks_cluster_nsg.name
#   priority                      = 103
#   direction                     = "Outbound"
#   access                        = "Deny"
#   protocol                      = "*"
#   source_port_range             = "*"
#   destination_port_range        = "*"
#   source_address_prefixes       = concat(
#                                     azurerm_subnet.node_subnet_1.address_prefixes,
#                                     azurerm_subnet.node_subnet_2.address_prefixes
#                                 ) #["10.0.120.0/21"]
#   destination_address_prefixes = ["0.0.0.0/0"]
# }
