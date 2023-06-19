# Define the virtual network and subnets for AKS
module "vnet" {
  source = "./modules/vnet"
  resource_group_name   = azurerm_resource_group.aks_cluster_rg.name 
  location              = azurerm_resource_group.aks_cluster_rg.location 
  name                  = var.aks_config.vnet_name
  address_space         = [ var.aks_config.vnet_cidr ]
}
module "aks_subnets" {
  resource_group_name   = azurerm_resource_group.aks_cluster_rg.name 
  virtual_network_name  = var.aks_config.vnet_name
  source = "./modules/subnet"
  #subnet_ids = var.aks_config.
}
# resource "azurerm_subnet" "aks_subnets" {
#   for_each              = var.aks_config.subnets_map
#   resource_group_name   = var.aks_config.rg # azurerm_resource_group.aks_cluster_rg.name # var.aks_cluster_rg
#   virtual_network_name  = var.aks_config.vnet_name
#                         # azurerm_virtual_network.aks_vnet.name # var.aks_cluster_vnet_name
#   name                  = each.key
#   address_prefixes      = each.value.address_prefixes
#   dynamic "delegation" { # Grant cluster access to manage subnets
#     for_each = var.aks_config.subnets_map[each.key].service_delegation_name != null ? [var.aks_config.subnets_map[each.key].service_delegation_name] : []
#     content {
#       name      = "${var.aks_config.subnets_map[each.key].service_delegation_name}-delegation"
#       service_delegation {
#         name    = var.aks_config.subnets_map[each.key].service_delegation_name
#         actions = var.aks_config.subnets_map[each.key].actions
#       }
#     }
#   }
# } 
# locals {
#   subnet_ids = { for subnet_name, subnet in azurerm_subnet.aks_subnets : subnet_name => subnet.id }
# }
# output "subnet_ids" {
#   value = local.subnet_ids
# }
