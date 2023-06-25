resource "azurerm_user_assigned_identity" "this" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
}
output "identity_id" {
  value = azurerm_user_assigned_identity.this.id
}