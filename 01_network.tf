# Define the virtual network and subnets for AKS
variable "my_service_cidr" {
    type = string
    default = "10.255.0.0/16"
}

variable "my_service_dns" {
    type = string
    default = "10.255.0.4"
}

resource "azurerm_virtual_network" "aks_vnet" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  location              = azurerm_resource_group.aks_rg.location
  name                  = "aks-vnet"
  address_space         = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_node_pool" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "default-node-pool"
  address_prefixes      = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_firewall_subnet" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "aks-firewall-subnet"
  address_prefixes      = ["10.0.0.0/24"]
  delegation {
    name      = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}

resource "azurerm_subnet" "backend_service_subnet" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "aks-backend-service-subnet"
  address_prefixes      = ["10.0.2.0/24"]
  delegation {
    name      = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}

# 32 /27 subnets taken from 10.0.124.1 - 10.0.127.255
# 8 /27 node subnets per /24. 4 of those from 10.0.[124-127].0 
resource "azurerm_subnet" "node_subnet_1" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "aks-node-subnet-1"
  address_prefixes      = ["10.0.124.0/27"]
  delegation {
    name = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}

resource "azurerm_subnet" "node_subnet_2" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "aks-node-subnet-2"
  address_prefixes      = ["10.0.124.32/27"]
  delegation {
    name      = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}

# 32 /22 pod subnets taken from 10.0.128.0/17
resource "azurerm_subnet" "default_pod_pool" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "default_pod_pool"
  address_prefixes      = ["10.0.128.0/22"]
  delegation {
    name      = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}

resource "azurerm_subnet" "pod_subnet_1" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "aks-pod-subnet-1"
  address_prefixes      = ["10.0.132.0/22"]
  delegation {
    name      = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}

resource "azurerm_subnet" "pod_subnet_2" {
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_name  = azurerm_virtual_network.aks_vnet.name
  name                  = "aks-pod-subnet-2"
  address_prefixes      = ["10.0.136.0/22"]
  delegation {
    name      = "name-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [ "Microsoft.Network/networkinterfaces/*" ]
    }
  }
}
