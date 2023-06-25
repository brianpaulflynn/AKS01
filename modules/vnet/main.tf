resource "azurerm_virtual_network" "aks_vnet" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name
  address_space       = var.address_space
}
output "vnet_name" {
  value = azurerm_virtual_network.aks_vnet.name
}