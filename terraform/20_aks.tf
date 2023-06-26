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
  # ADD FOR EACH HERE THAT USES A MAP IN THE aks_config VARIABLE
  source                = "../modules/aks_node_pool"
  kubernetes_cluster_id = module.aks_cluster.aks_cluster_id
  vnet_subnet_id        = module.aks_subnets.aks_node_subnet_ids["aks_user_pool_1"]
  pod_subnet_id         = module.aks_subnets.aks_pod_subnet_ids["aks_user_pool_1"]
  vm_size               = var.aks_config.node_pool_map["aks_user_pool_1"].vm_size
  zones                 = var.aks_config.node_pool_map["aks_user_pool_1"].zones
  enable_auto_scaling   = var.aks_config.node_pool_map["aks_user_pool_1"].enable_auto_scaling
  name                  = var.aks_config.node_pool_map["aks_user_pool_1"].name
  Environment           = var.aks_config.node_pool_map["aks_user_pool_1"].Environment
  os_disk_size_gb       = var.aks_config.node_pool_map["aks_user_pool_1"].os_disk_size_gb
  min_count             = var.aks_config.node_pool_map["aks_user_pool_1"].min_count
  max_count             = var.aks_config.node_pool_map["aks_user_pool_1"].max_count
  max_pods              = var.aks_config.node_pool_map["aks_user_pool_1"].max_pods
}
