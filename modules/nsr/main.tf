resource "azurerm_network_security_rule" "allow_pod_subnet_outbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
  name                        = var.name
  priority                    = var.priority
  direction                   = var.direction
  access                      = var.access
  protocol                    = var.protocol
  source_port_range           = var.source_port_range
  destination_port_range      = var.destination_port_range
  source_address_prefixes       = var.source_address_prefixes
  destination_address_prefixes  = var.destination_address_prefixes
  }


# resource "azurerm_network_security_rule" "allow_pod_to_pod" {
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = var.network_security_group_name
#   name                        = "pod-to-pod-inbound"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   dynamic "source_address_prefixes" {
#     for_each = {
#       for pool in var.node_pool_map :
#       pool.name => pool
#       if substr(pool.name, length(pool.name) - 3) == "_pod"
#     }
#     content {
#       address_prefixes = source_address_prefixes.value.pod_address_prefixes
#     }
#   }
#   dynamic "destination_address_prefixes" {
#     for_each = {
#       for pool in var.node_pool_map :
#       pool.name => pool
#       if substr(pool.name, length(pool.name) - 3) == "_pod"
#     }
#     content {
#       address_prefixes = source_address_prefixes.value.pod_address_prefixes
#     }
#   }
# }
# resource "azurerm_network_security_rule" "deny_node_to_pod_subnet" {
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = var.network_security_group_name
#   name                        = "deny-node-to-pod-subnet"
#   priority                    = 101
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   dynamic "source_address_prefixes" {
#     for_each = {
#       for pool in var.node_pool_map :
#       pool.name => pool
#       if substr(pool.name, length(pool.name) - 3) == "_pod"
#     }
#     content {
#       address_prefixes = source_address_prefixes.value.node_address_prefixes
#     }
#   }
#   dynamic "destination_address_prefixes" {
#     for_each = {
#       for pool in var.node_pool_map :
#       pool.name => pool
#       if substr(pool.name, length(pool.name) - 3) == "_pod"
#     }
#     content {
#       address_prefixes = source_address_prefixes.value.pod_address_prefixes
#     }
#   }
# }
# resource "azurerm_network_security_rule" "deny_pod_to_node_subnet" {
#   name                        = "deny-pod-to-node-subnet"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = var.network_security_group_name
#   priority                    = 102
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   dynamic "source_address_prefixes" {
#     for_each = {
#       for pool in var.node_pool_map :
#       pool.name => pool
#       if substr(pool.name, length(pool.name) - 3) == "_pod"
#     }
#     content {
#       address_prefixes = source_address_prefixes.value.pod_address_prefixes
#     }
#   }
#   dynamic "destination_address_prefixes" {
#     for_each = {
#       for pool in var.node_pool_map :
#       pool.name => pool
#       if substr(pool.name, length(pool.name) - 4) == "_node"
#     }
#     content {
#       address_prefixes = source_address_prefixes.value.node_address_prefixes
#     }
#   }
# }