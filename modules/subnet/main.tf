resource "azurerm_subnet" "aks_subnets" {
  for_each              = var.aks_config.subnets_map
  resource_group_name   = var.resource_group_name
  virtual_network_name  = var.virtual_network_name
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
locals {
  subnet_ids = { for subnet_name, subnet in azurerm_subnet.aks_subnets : subnet_name => subnet.id }
}
output "subnet_ids" {
  value =  { for subnet_name, subnet in azurerm_subnet.aks_subnets : subnet_name => subnet.id }
}