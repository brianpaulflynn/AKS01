resource "azurerm_user_assigned_identity" "aks_cluster_identity" {
  location            = var.location # var.aks_config.location
  name                = var.name # "${var.aks_config.name}-identity" # "aks-cluster-identity"
  resource_group_name = var.resource_group_name # azurerm_resource_group.aks_cluster_rg.name
}