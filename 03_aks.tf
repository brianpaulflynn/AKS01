# Define AKS Cluster
module "aks_cluster" {
  source = "./modules/aks_cluster"
  AD_GROUP_ID                     = var.AD_GROUP_ID # TF Env Var
  aks_managed_identity_ids        = [azurerm_user_assigned_identity.aks_cluster_identity.id]
  aks_log_analytics_workspace_id  = azurerm_log_analytics_workspace.aks_log_analytics.id
  subnet_ids                      = module.aks_subnets.subnet_ids
  aks_config                      = var.aks_config
}
