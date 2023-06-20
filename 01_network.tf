# Define the virtual network and subnets for AKS
module "aks_vnet" {
  source              = "./modules/vnet"
  resource_group_name = module.aks_cluster_rg.rg_name
  location            = module.aks_cluster_rg.rg_location
  name                = var.aks_config.vnet_name
  address_space       = [var.aks_config.vnet_cidr]
}
module "aks_subnets" {
  source               = "./modules/subnet"
  resource_group_name  = module.aks_cluster_rg.rg_name
  virtual_network_name = module.aks_vnet.vnet_name
}
