# Define the resource group
module "aks_cluster_rg" {
  source   = "./modules/rg"
  location = var.aks_config.location
  name     = var.aks_config.rg
}
# # Create Azure Log Analytics Workspace
module "aks_log_analytics" {
  source              = "./modules/log_analytics_workspace"
  location            = var.aks_config.location
  sku                 = var.aks_config.log_analytics_workspace_sku
  name                = "${var.aks_config.name}-analytics" #"aks-cluster-log-analytics"
  resource_group_name = module.aks_cluster_rg.rg_name
}
# Create aks cluster identity
module "aks_cluster_identity" {
  source              = "./modules/user_assigned_identity"
  location            = var.aks_config.location
  name                = "${var.aks_config.name}-identity" # "aks-cluster-identity"
  resource_group_name = module.aks_cluster_rg.rg_name     # azurerm_resource_group.aks_cluster_rg.name
}
