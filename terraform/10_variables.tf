variable "AD_GROUP_ID" { type = string } # TF_VAR
variable "aks_config" {
  type = object({
    default_node_pool_sku             = string
    log_analytics_workspace_sku       = string
    loadBalancer_type                 = string
    location                          = string
    rg                                = string
    nodes_rg                          = string
    name                              = string
    vnet_name                         = string
    dns_prefix                        = string
    service_cidr                      = string
    service_dns                       = string
    vnet_cidr                         = string
    default_node_pool_zones           = list(string)
    default_node_pool_name            = string
    default_node_pool_os_disk_size_gb = string
    default_node_pool_min_count       = string
    default_node_pool_max_count       = string
    default_node_pool_max_pods        = string
    run_command_enabled               = string
    public_network_access_enabled     = string
    private_cluster_enabled           = string
    node_pool_map = map(object({
      node_address_prefixes = list(string)
      pod_address_prefixes  = list(string)
      max_pods              = string
      name                  = string
      Environment           = string
      vm_size               = string
      os_disk_size_gb       = string
      zones                 = list(number)
      enable_auto_scaling   = string
      min_count             = string
      max_count             = string
    }))
  })
  default = {
    log_analytics_workspace_sku       = "PerGB2018"
    loadBalancer_type                 = "loadBalancer"
    location                          = "eastus"
    rg                                = "my_aks_rg"
    nodes_rg                          = "my_nodes_rg"
    name                              = "aks-cluster"
    vnet_name                         = "aks-cluster-vnet"
    dns_prefix                        = "aks-cluster-dns"
    default_node_pool_name            = "default"
    default_node_pool_sku             = "Standard_B2s"
    default_node_pool_zones           = [1, 2, 3]
    default_node_pool_os_disk_size_gb = 30
    default_node_pool_min_count       = 1
    default_node_pool_max_count       = 3
    default_node_pool_max_pods        = 32
    run_command_enabled               = false # Best Practice for Prodcution Servers
    public_network_access_enabled     = false # Best Practice Default
    private_cluster_enabled           = true  # Best Practice Default
    service_cidr                      = "10.255.0.0/16"
    service_dns                       = "10.255.0.4"
    vnet_cidr                         = "10.0.0.0/16"
    node_pool_map = {
      aks_default_pool = {
        node_address_prefixes = ["10.0.123.224/27"]
        pod_address_prefixes  = ["10.0.128.0/22"]
        max_pods              = 32 # Needs to be determined by network math. 2^(node_mask-pod_mask)
        name                  = "default"
        Environment           = "defaultTag"
        vm_size               = "Standard_B2s"
        enable_auto_scaling   = true
        os_disk_size_gb       = 30
        zones                 = [1, 2, 3]
        min_count             = 1
        max_count             = 3
      }
      aks_user_pool_1 = {
        node_address_prefixes = ["10.0.124.0/27"]
        pod_address_prefixes  = ["10.0.132.0/22"]
        max_pods              = 32 # Do not exceed 2^(node_mask-pod_mask)
        # ex: /27 & /22 are /5 apart.  2^(27-22) = 2^5 That makes for 32:1 pods:nodes.
        #     /29 is the smallest Azure subnet. Provides 3 usable IPs.
        name                = "pool1"
        Environment         = "Pool1Tag"
        vm_size             = "Standard_B2s"
        enable_auto_scaling = true
        os_disk_size_gb     = 30
        zones               = [1, 2, 3]
        min_count           = 1
        max_count           = 3
      },
      aks_user_pool_2 = {
        node_address_prefixes = ["10.0.124.32/27"]
        pod_address_prefixes  = ["10.0.136.0/22"]
        max_pods              = 32 # Needs to be determined by network math. 2^(node_mask-pod_mask)
        # ex: /27 & /22 are /5 apart.  2^(27-22) = 2^5 That makes for 32:1 pods:nodes.
        #     /29 is the smallest Azure subnet. Provides 3 usable IPs.
        name                = "pool2"
        Environment         = "Pool2Tag"
        vm_size             = "Standard_B2s"
        enable_auto_scaling = true
        zones               = [1, 2, 3]
        os_disk_size_gb     = 30
        min_count           = 1
        max_count           = 3
      }
    }
  }
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}
