# Create Azure Log Analytics Workspace
module "aks_log_analytics" {
  source              = "../modules/log_analytics_workspace"
  location            = var.aks_config.location
  sku                 = var.aks_config.log_analytics_workspace_sku
  name                = "${var.aks_config.name}-analytics"
  resource_group_name = module.aks_cluster_rg.rg_name
}
# Create aks cluster identity
module "aks_cluster_identity" {
  source              = "../modules/user_assigned_identity"
  location            = var.aks_config.location
  name                = "${var.aks_config.name}-identity"
  resource_group_name = module.aks_cluster_rg.rg_name
}
# Define AKS Cluster
module "aks_cluster" {
  source                         = "../modules/aks_cluster"
  AD_GROUP_ID                    = var.AD_GROUP_ID # TF Env Var
  aks_config                     = var.aks_config
  aks_log_analytics_workspace_id = module.aks_log_analytics.log_analytics_workspace_id
  vnet_subnet_ids                = module.aks_subnets.aks_node_subnet_ids
  pod_subnet_ids                 = module.aks_subnets.aks_pod_subnet_ids
  aks_managed_identity_ids       = [module.aks_cluster_identity.identity_id]
}
#Define User Pools
module "aks_user_pools" {
  source                = "../modules/aks_node_pool"
  kubernetes_cluster_id = module.aks_cluster.aks_cluster_id
  for_each = {
    for k, v
    in var.aks_config.node_pool_map : k => v
    if k != "aks_default_pool"
  }
  vnet_subnet_id      = module.aks_subnets.aks_node_subnet_ids[each.key]
  pod_subnet_id       = module.aks_subnets.aks_pod_subnet_ids[each.key]
  vm_size             = var.aks_config.node_pool_map[each.key].vm_size
  zones               = var.aks_config.node_pool_map[each.key].zones
  enable_auto_scaling = var.aks_config.node_pool_map[each.key].enable_auto_scaling
  name                = var.aks_config.node_pool_map[each.key].name
  Environment         = var.aks_config.node_pool_map[each.key].Environment
  os_disk_size_gb     = var.aks_config.node_pool_map[each.key].os_disk_size_gb
  min_count           = var.aks_config.node_pool_map[each.key].min_count
  max_count           = var.aks_config.node_pool_map[each.key].max_count
  max_pods            = var.aks_config.node_pool_map[each.key].max_pods
}
