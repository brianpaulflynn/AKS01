# Define the AKS network security group (NSG)
#resource "azurerm_network_security_group" "aks_nsg" {
module "aks_nsg" {
  source              = "./modules/nsg"
  name                = "${var.aks_config.name}-nsg"
  resource_group_name = module.aks_cluster_rg.rg_name     #azurerm_resource_group.aks_cluster_rg.name
  location            = module.aks_cluster_rg.rg_location #azurerm_resource_group.aks_cluster_rg.location
}
module "subnets_nsg_association" {
  source                    = "./modules/nsga"
  for_each                  = var.aks_config.subnets_map
  subnets_map               = var.aks_config.subnets_map
  subnet_id                 = module.aks_subnets.subnet_ids[each.key]
  network_security_group_id = module.aks_nsg.network_security_group_id
}
# Define NSG rules
module "allow_pod_subnet_outbound" {
  source                      = "./modules/nsr"
  subnets_map                 = var.aks_config.subnets_map
  name                        = "pod-subnet-outbound"
  resource_group_name         = module.aks_cluster_rg.rg_name #azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name = module.aks_nsg.network_security_group_name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
  ) #["10.0.128.0/17"]
  destination_address_prefixes = ["0.0.0.0/0"]
}
module "allow_pod_to_pod" {
  source      = "./modules/nsr"
  subnets_map = var.aks_config.subnets_map

  name                        = "pod-to-pod-inbound"
  resource_group_name         = module.aks_cluster_rg.rg_name              #azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name = module.aks_nsg.network_security_group_name # var.network_security_group_name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
  )
  destination_address_prefixes = concat(
    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
  ) # ["10.0.128.0/17"]
}
module "deny_node_to_pod_subnet" {
  source      = "./modules/nsr"
  subnets_map = var.aks_config.subnets_map

  name                        = "deny-node-to-pod-subnet"
  resource_group_name         = module.aks_cluster_rg.rg_name              #azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name = module.aks_nsg.network_security_group_name # var.network_security_group_name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.subnets_map["aks_node_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_node_subnet_2"].address_prefixes
  ) # ["10.0.120.0/21"]
  destination_address_prefixes = concat(
    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
  ) # ["10.0.128.0/17"]
}
module "deny_pod_to_node_subnet" {
  source      = "./modules/nsr"
  subnets_map = var.aks_config.subnets_map

  name                        = "deny-pod-to-node-subnet"
  resource_group_name         = module.aks_cluster_rg.rg_name #azurerm_resource_group.aks_cluster_rg.name
  network_security_group_name = module.aks_nsg.network_security_group_name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes = concat(
    var.aks_config.subnets_map["aks_pod_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_pod_subnet_2"].address_prefixes
  ) # ["10.0.128.0/17"]
  destination_address_prefixes = concat(
    var.aks_config.subnets_map["aks_node_subnet_1"].address_prefixes,
    var.aks_config.subnets_map["aks_node_subnet_2"].address_prefixes
  ) # ["10.0.120.0/21"]
}
