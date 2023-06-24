# Define AKS Cluster
module "aks_cluster" {
  source                         = "../modules/aks_cluster"
  aks_config                     = var.aks_config
  AD_GROUP_ID                    = var.AD_GROUP_ID # TF Env Var
  aks_managed_identity_ids       = [module.aks_cluster_identity.identity_id]
  aks_log_analytics_workspace_id = module.aks_log_analytics.log_analytics_workspace_id
  subnet_ids                     = module.aks_subnets.subnet_ids
}
# Define AKS Pools
# Suggestion: Define Availability Sets for node_pools to improve resiliency.
module "aks_node_pool_1" {
  # ADD FOR EACH HERE THAT USES A MAP IN THE aks_config VARIABLE
  source                = "../modules/aks_node_pool" # we may want many different node pools defined in modules that all inherit this.
  max_pods              = 32              # CONSIDER: make this not exposed. Make it determined by network math. 2^(node_mask/pod_mask)
  vm_size               = "Standard_B2s"  # CONSIDER: holding back in modules defined to expose configured skus to developers.
  os_disk_size_gb       = 30              # CONSIDER: holding back in modules defined to expose configured skus to developers.
  zones                 = [1, 2, 3]       # CONSIDER: holding back in modules defined to expose configured skus to developers.
  enable_auto_scaling   = true            # CONSIDER: holding back in modules defined to expose configured skus to developers.

  kubernetes_cluster_id = module.aks_cluster.aks_cluster_id
  vnet_subnet_id        = module.aks_subnets.subnet_ids["aks_node_subnet_1"]    # var.aks_config.???
  pod_subnet_id         = module.aks_subnets.subnet_ids["aks_pod_subnet_1"]     # var.aks_config.???
  name                  = "pool1"         # CONSIDER: making available to developers via var.aks_config.
  Environment           = "Pool1Tag"      # CONSIDER: making available to developers via var.aks_config.
  min_count             = 1               # CONSIDER: making available to developers via var.aks_config.
  max_count             = 3               # CONSIDER: making available to developers via var.aks_config.
}
