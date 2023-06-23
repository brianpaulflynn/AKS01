resource "azurerm_subnet_network_security_group_association" "subnets_nsg_association" {
  #for_each                      = var.subnets_map # var.aks_config.subnets_map
  subnet_id                     = var.subnet_id # module.aks_subnets.subnet_ids[each.key]
  network_security_group_id     = var.network_security_group_id # module.aks_nsg.network_security_group_id
}
output "network_security_group_id" {
 value = azurerm_subnet_network_security_group_association.subnets_nsg_association.id
          #{ for subnet_name, subnet in azurerm_subnet_network_security_group_association.subnets_nsg_association : subnet_name => subnet.id }
}