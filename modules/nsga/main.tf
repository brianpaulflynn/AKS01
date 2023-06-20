resource "azurerm_subnet_network_security_group_association" "subnets_nsg_association" {
  subnet_id                     = var.subnet_id 
  network_security_group_id     = var.network_security_group_id 
}
output "network_security_group_id" {
  value = azurerm_subnet_network_security_group_association.subnets_nsg_association.id
}