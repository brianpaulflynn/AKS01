# Define the resource group
module "aks_rg" {
  source   = "../modules/rg"
  location = var.aks_config.location
  name     = var.aks_config.rg
}
# Define the virtual network and subnets for AKS
module "aks_vnet" {
  source              = "../modules/vnet"
  resource_group_name = module.aks_rg.rg_name
  location            = module.aks_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
module "aks_subnets" {
  source               = "../modules/aks_subnet"
  resource_group_name  = module.aks_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
  node_pool_map        = var.aks_config.node_pool_map
}
# Define the AKS network security group (NSG)
module "aks_nsg" {
  source              = "../modules/nsg"
  resource_group_name = module.aks_rg.rg_name
  location            = module.aks_rg.rg_location
  name                = "${var.aks_config.name}-nsg"
}
# Define the NSG associations for each node subnet
module "aks_subnets_nsg_associations_nodes" {
  source                    = "../modules/nsga"
  for_each                  = module.aks_subnets.aks_node_subnet_ids
  subnet_id                 = module.aks_subnets.aks_node_subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
# Define the NSG associations for each pod subnet
module "aks_subnets_nsg_associations_pods" {
  source                    = "../modules/nsga"
  for_each                  = module.aks_subnets.aks_pod_subnet_ids
  subnet_id                 = module.aks_subnets.aks_pod_subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
# Define Network Security Group Rules for the AKS vnet
module "aks_nsrs" {
  source                      = "../modules/aks_nsrs"
  resource_group_name         = module.aks_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
  node_pool_map               = var.aks_config.node_pool_map
}
# Create Azure Log Analytics Workspace
module "aks_log_analytics" {
  source              = "../modules/log_analytics_workspace"
  resource_group_name = module.aks_rg.rg_name
  location            = var.aks_config.location
  sku                 = var.aks_config.log_analytics_workspace_sku
  name                = "${var.aks_config.name}-analytics"
}
# Create aks cluster identity
module "aks_cluster_identity" {
  resource_group_name = module.aks_rg.rg_name
  source              = "../modules/user_assigned_identity"
  location            = var.aks_config.location
  name                = "${var.aks_config.name}-identity"
}
# Define AKS Cluster
module "aks_cluster" {
  source                         = "../modules/aks_cluster"
  aks_log_analytics_workspace_id = module.aks_log_analytics.log_analytics_workspace_id
  vnet_subnet_ids                = module.aks_subnets.aks_node_subnet_ids
  pod_subnet_ids                 = module.aks_subnets.aks_pod_subnet_ids
  aks_managed_identity_ids       = [module.aks_cluster_identity.identity_id]
  AD_GROUP_ID                    = var.AD_GROUP_ID # TF Env Var
  aks_config                     = var.aks_config
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
