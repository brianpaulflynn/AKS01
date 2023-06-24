resource "azurerm_network_security_rule" "this" {
  name                          = var.name 
  resource_group_name           = var.resource_group_name 
  network_security_group_name   = var.network_security_group_name 
  priority                      = var.priority 
  direction                     = var.direction 
  access                        = var.access 
  protocol                      = var.protocol
  source_port_range             = var.source_port_range 
  destination_port_range        = var.destination_port_range 
  source_address_prefixes       = concat( 
                                    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.node_pool_map.node_address_prefixes["aks_pod_subnet_2"].address_prefixes
                                ) 
  destination_address_prefixes  = var.destination_address_prefixes
}
