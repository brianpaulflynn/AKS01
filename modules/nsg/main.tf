resource "azurerm_network_security_group" "aks_cluster_nsg" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
}
output "network_security_group_id" {
    value = azurerm_network_security_group.aks_cluster_nsg.id
}
output "network_security_group_name" {
    value = azurerm_network_security_group.aks_cluster_nsg.name
}