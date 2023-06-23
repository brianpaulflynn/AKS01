resource "azurerm_log_analytics_workspace" "this" {
  location            = var.location
  sku                 = var.sku
  name                = var.name
  resource_group_name = var.resource_group_name
}
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}