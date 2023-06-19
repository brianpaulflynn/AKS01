# Create Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  location            = var.location # var.aks_config.location
  sku                 = var.sku # var.aks_config.log_analytics_workspace_sku
  name                = var.name # "${var.aks_config.name}-analytics" #"aks-cluster-log-analytics"
  resource_group_name = var.resource_group_name # azurerm_resource_group.aks_cluster_rg.name # #var.aks_cluster_rg
}
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}