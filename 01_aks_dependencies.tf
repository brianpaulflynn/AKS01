# Define the resource group
resource "azurerm_resource_group" "aks_cluster_rg" {
  location            = var.aks_config.location
  name                = var.aks_config.rg
}
output "aks_cluster_rg_name" {
  value = azurerm_resource_group.aks_cluster_rg.name
}
output "aks_cluster_location" {
  value = azurerm_resource_group.aks_cluster_rg.location
}
# Create Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_log_analytics" {
  location            = var.aks_config.location
  sku                 = var.aks_config.log_analytics_workspace_sku
  name                = "${var.aks_config.name}-analytics" #"aks-cluster-log-analytics"
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name # #var.aks_cluster_rg
}
output "aks_log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.aks_log_analytics.id
}


module "user_assigned_identity" {
  source = "./modules/user_assigned_identity"
  location            = var.aks_config.location
  name                = "${var.aks_config.name}-identity" # "aks-cluster-identity"
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name
  }
