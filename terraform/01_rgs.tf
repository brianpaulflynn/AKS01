# Define the resource group
module "aks_cluster_rg" {
  source   = "../modules/rg"
  location = var.aks_config.location
  name     = var.aks_config.rg
}
