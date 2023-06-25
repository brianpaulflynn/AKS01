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
module "aks_node_pool_1" {
  source                = "../modules/aks_node_pool"
  for_each              = var.aks_config.node_pool_map
  kubernetes_cluster_id = module.aks_cluster.aks_cluster_id
  vnet_subnet_id        = module.aks_subnets.aks_node_subnet_ids[each.key]
  pod_subnet_id         = module.aks_subnets.aks_pod_subnet_ids[each.key]
  vm_size               = var.aks_config.node_pool_map[each.key].vm_size
  zones                 = var.aks_config.node_pool_map[each.key].zones
  enable_auto_scaling   = var.aks_config.node_pool_map[each.key].enable_auto_scaling
  name                  = var.aks_config.node_pool_map[each.key].name
  Environment           = var.aks_config.node_pool_map[each.key].Environment
  os_disk_size_gb       = var.aks_config.node_pool_map[each.key].os_disk_size_gb
  min_count             = var.aks_config.node_pool_map[each.key].min_count
  max_count             = var.aks_config.node_pool_map[each.key].max_count
  max_pods              = var.aks_config.node_pool_map[each.key].max_pods
}
