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
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name # #var.aks_cluster_rg
  sku                 = var.aks_config.log_analytics_workspace_sku
  name                = "${var.aks_config.name}-analytics" #"aks-cluster-log-analytics"
}
output "aks_log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.aks_log_analytics.id
}
# Define user assigned identities
resource "azurerm_user_assigned_identity" "aks_cluster_identity" {
  location            = var.aks_config.location
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name
  name                = "${var.aks_config.name}-identity" # "aks-cluster-identity"
}

# # Grant AKS cluster access to use AKS vnet
# resource "azurerm_role_assignment" "aks-cluster-access" {
#   role_definition_name = "Network Contributor"
#   scope                = azurerm_subnet.aks_subnets["aks_backend_service_subnet"].id
#                           # azurerm_subnet.aks_subnets[each.key].id
#                           # azurerm_subnet.backend_service_subnet.id
#   principal_id         = azurerm_user_assigned_identity.aks_cluster_identity.principal_id
#  }

