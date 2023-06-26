# Define the resource group
module "aks_cluster_rg" {
  source   = "../modules/rg"
  location = var.aks_config.location
  name     = var.aks_config.rg
}
# Define the virtual network and subnets for AKS
module "aks_vnet" {
  source              = "../modules/vnet"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
module "aks_subnets" {
  source               = "../modules/subnet"
  resource_group_name  = module.aks_cluster_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
  node_pool_map        = var.aks_config.node_pool_map
}
# Define the AKS network security group (NSG)
module "aks_nsg" {
  source              = "../modules/nsg"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = "${var.aks_config.name}-nsg"
}
# Define the NSG associations for each node subnet
module "subnets_nsg_associations_nodes" {
  source                    = "../modules/nsga"
  for_each                  = module.aks_subnets.aks_node_subnet_ids
  subnet_id                 = module.aks_subnets.aks_node_subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
# Define the NSG associations for each pod subnet
module "subnets_nsg_associations_pods" {
  source                    = "../modules/nsga"
  for_each                  = module.aks_subnets.aks_pod_subnet_ids
  subnet_id                 = module.aks_subnets.aks_pod_subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
module "aks_nsrs" {
  source                      = "../modules/aks_nsrs"
  node_pool_map               = var.aks_config.node_pool_map
  resource_group_name         = module.aks_cluster_rg.rg_name
  network_security_group_name = module.aks_nsg.network_security_group_name
}
