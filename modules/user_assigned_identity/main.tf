resource "azurerm_user_assigned_identity" "this" {
  location            = var.location # var.aks_config.location
  name                = var.name # "${var.aks_config.name}-identity" # "aks-cluster-identity"
  resource_group_name = var.resource_group_name # azurerm_resource_group.aks_cluster_rg.name
}
output "identity_id" {
  value = azurerm_user_assigned_identity.this.id
}