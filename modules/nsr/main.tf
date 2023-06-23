resource "azurerm_network_security_rule" "this" {
  name                          = var.name # "pod-subnet-outbound"
  resource_group_name           = var.resource_group_name # azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name   = var.network_security_group_name # module.aks_nsg.network_security_group_name
  priority                      = var.priority # 100
  direction                     = var.direction # "Outbound"
  access                        = var.access # "Allow"
  protocol                      = var.protocol # "*"
  source_port_range             = var.source_port_range # "*"
  destination_port_range        = var.destination_port_range # "*"
  source_address_prefixes       = concat( 
                                    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
                                    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
                                ) #["10.0.128.0/17"]
  destination_address_prefixes  = ["0.0.0.0/0"]
}