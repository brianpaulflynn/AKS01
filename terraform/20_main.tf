# Define a resource group for external dependencies
module "aks_dep_rg" {
  source   = "../modules/rg"
  location = var.aks_config.location
  name     = "${var.aks_config.name}-dependencies"
}
# Create Azure Log Analytics Workspace
# Keep this out of the aks module? As an external dependency?
module "aks_log_analytics" {
  source              = "../modules/log_analytics_workspace"
  resource_group_name = module.aks_dep_rg.rg_name
  location            = var.aks_config.location
  sku                 = var.aks_config.log_analytics_workspace_sku
  name                = "${var.aks_config.name}-analytics"
}
# Create aks cluster identity
# Keep this out of the aks module? As an external dependency?
module "aks_cluster_identity" {
  source              = "../modules/user_assigned_identity"
  resource_group_name = module.aks_dep_rg.rg_name
  location            = var.aks_config.location
  name                = "${var.aks_config.name}-identity"
}

# AKS module
module "aks_combined" {
  source                         = "../modules/aks_combined"
  aks_managed_identity_ids       = [module.aks_cluster_identity.identity_id]
  aks_log_analytics_workspace_id = module.aks_log_analytics.log_analytics_workspace_id
  AD_GROUP_ID                    = var.AD_GROUP_ID # TF Env Var
  aks_config                     = var.aks_config
}
