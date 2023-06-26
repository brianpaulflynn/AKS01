resource "azurerm_subnet" "aks_node_subnets" {
  for_each             = var.node_pool_map
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  name                 = "${each.key}_nodes"              # <=== NODES!
  address_prefixes     = each.value.node_address_prefixes # <=== NODES!
  dynamic "delegation" {                                  # Grant cluster access to manage subnets
    # rem no delegation for default node pool!
    for_each = each.key != "aks_default_pool" ? ["${each.key}_delegation"] : []
    content {
      name = "${each.key}_delegation"
      service_delegation {
        name    = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/networkinterfaces/*"]
      }
    }
  }
}
output "aks_node_subnet_ids" {
  value = { for subnet_name, subnet in azurerm_subnet.aks_node_subnets : subnet_name => subnet.id }
}
resource "azurerm_subnet" "aks_pod_subnets" {
  for_each             = var.node_pool_map
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  name                 = "${each.key}_pods"              # <=== PODS!
  address_prefixes     = each.value.pod_address_prefixes # <=== PODS!

  dynamic "delegation" { # Grant cluster access to manage subnets
    # delegation required on all pod pools, even default... this needs to be cleaner
    for_each = each.key != "fdsafdsa" ? ["${each.key}_delegation"] : []
    content {
      name = "${each.key}_delegation"
      service_delegation {
        name    = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/networkinterfaces/*"]
      }
    }
  }
}
output "aks_pod_subnet_ids" {
  value = { for subnet_name, subnet in azurerm_subnet.aks_pod_subnets : subnet_name => subnet.id }
}

