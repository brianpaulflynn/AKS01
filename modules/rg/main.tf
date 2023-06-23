resource "azurerm_resource_group" "this" {
  location  = var.location # var.aks_config.location
  name      = var.name # var.aks_config.rg
}
output "rg_name" {
    value = azurerm_resource_group.this.name
}
output "rg_id" {
    value = azurerm_resource_group.this.id
}
output "rg_location" {
    value = azurerm_resource_group.this.location
}
