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
# Define AKS Pools
# Suggestion: Define Availability Sets for node_pools to improve resiliency.
module "aks_node_pool_1" {
  # ADD FOR EACH HERE THAT USES A MAP IN THE aks_config VARIABLE
  source                = "../modules/aks_node_pool"
  kubernetes_cluster_id = module.aks_cluster.aks_cluster_id
  vnet_subnet_id        = module.aks_subnets.aks_node_subnet_ids["aks_user_pool_1"]
  pod_subnet_id         = module.aks_subnets.aks_pod_subnet_ids["aks_user_pool_1"]
  max_pods              = 32 # Needs to be determined by network math. 2^(node_mask-pod_mask)
  # ex: /27 & /22 are /5 apart.  That makes for 32:1 pods:nodes.
  #     /29 is the smallest Azure subnet. Provides 3 usable IPs.
  # CONSIDER: holding back in modules defined to expose configured skus to developers.
  zones               = [1, 2, 3] # Use all zones for max resiliency.
  vm_size             = "Standard_B2s"
  os_disk_size_gb     = 30
  enable_auto_scaling = true
  # CONSIDER: making available to developers via var.aks_config.
  name        = "pool1"
  Environment = "Pool1Tag"
  min_count   = 1
  max_count   = 3
}
module "aks_node_pool_2" {
  # ADD FOR EACH HERE THAT USES A MAP IN THE aks_config VARIABLE
  source                = "../modules/aks_node_pool"
  kubernetes_cluster_id = module.aks_cluster.aks_cluster_id
  vnet_subnet_id        = module.aks_subnets.aks_node_subnet_ids["aks_user_pool_2"]
  pod_subnet_id         = module.aks_subnets.aks_pod_subnet_ids["aks_user_pool_2"]
  max_pods              = 32 # Needs to be determined by network math. 2^(node_mask/pod_mask)
  # ex: /27 & /22 are /5 apart.  That makes for 32:1 pods:nodes.
  #     /29 is the smallest Azure subnet. Provides 3 usable IPs.
  # CONSIDER: holding back in modules defined to expose configured skus to developers.
  zones               = [1, 2, 3] # Use all zones for max resiliency.
  vm_size             = "Standard_B2s"
  os_disk_size_gb     = 30
  enable_auto_scaling = true
  # CONSIDER: making available to developers via var.aks_config.
  name        = "pool2"
  Environment = "Pool2Tag"
  min_count   = 1
  max_count   = 3
}