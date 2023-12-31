resource "azurerm_network_security_rule" "allow_pod_subnet_outbound" {
  name                         = "allow-pod-subnet-outbound"
  resource_group_name          = var.resource_group_name
  network_security_group_name  = var.network_security_group_name
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = var.node_subnet_prefixes
  destination_address_prefixes = ["0.0.0.0/0"]
}
resource "azurerm_network_security_rule" "allow_pod_to_pod" {
  name                         = "allow-pod-to-pod-inbound"
  resource_group_name          = var.resource_group_name
  network_security_group_name  = var.network_security_group_name
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = var.pod_subnet_prefixes
  destination_address_prefixes = var.pod_subnet_prefixes
}
resource "azurerm_network_security_rule" "deny_node_to_pod_subnet" {
  name                         = "deny-node-to-pod-subnet"
  resource_group_name          = var.resource_group_name
  network_security_group_name  = var.network_security_group_name
  priority                     = 101
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = var.node_subnet_prefixes
  destination_address_prefixes = var.pod_subnet_prefixes
}
resource "azurerm_network_security_rule" "deny_pod_to_node_subnet" {
  name                         = "deny-pod-to-node-subnet"
  resource_group_name          = var.resource_group_name
  network_security_group_name  = var.network_security_group_name
  priority                     = 102
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = var.node_subnet_prefixes
  destination_address_prefixes = var.node_subnet_prefixes
}
