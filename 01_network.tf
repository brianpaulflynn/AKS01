# Define the virtual network and subnets for AKS
resource "azurerm_virtual_network" "aks_vnet" {
  resource_group_name   = azurerm_resource_group.aks_cluster_rg.name #var.aks_cluster_rg
  location              = var.aks_config.aks_location
  name                  = var.aks_config.aks_cluster_vnet_name
  address_space         = [ var.aks_config.aks_cluster_vnet_cidr ]
}
resource "azurerm_subnet" "aks_subnets" {
  for_each              = var.aks_config.subnets_map
  resource_group_name   = azurerm_resource_group.aks_cluster_rg.name # var.aks_cluster_rg
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name # var.aks_cluster_vnet_name
  name                  = each.key
  address_prefixes      = each.value.address_prefixes
  dynamic "delegation" { # Grant cluster access to manage subnets
    for_each = var.aks_config.subnets_map[each.key].service_delegation_name != null ? [var.aks_config.subnets_map[each.key].service_delegation_name] : []
    content {
      name      = "${var.aks_config.subnets_map[each.key].service_delegation_name}-delegation"
      service_delegation {
        name    = var.aks_config.subnets_map[each.key].service_delegation_name
        actions = var.aks_config.subnets_map[each.key].actions
      }
    }
  }
} 