variable "node_pool_map" {
  type = map(object({
    node_address_prefixes = list(string)
    pod_address_prefixes  = list(string)
    name                  = string
    Environment           = string
    min_count             = string
    max_count             = string
  }))
}
variable "resource_group_name" {
  type = string
}
variable "virtual_network_name" {
  type = string
}


# variable "aks_config" {
#   type = object({
#     default_node_pool_sku             = string
#     log_analytics_workspace_sku       = string
#     loadBalancer_type                 = string
#     location                          = string
#     rg                                = string
#     nodes_rg                          = string
#     name                              = string
#     vnet_name                         = string
#     dns_prefix                        = string
#     service_cidr                      = string
#     service_dns                       = string
#     vnet_cidr                         = string
#     default_node_pool_zones           = list(string)
#     default_node_pool_name            = string
#     default_node_pool_os_disk_size_gb = string
#     default_node_pool_min_count       = string
#     default_node_pool_max_count       = string
#     default_node_pool_max_pods        = string
#     run_command_enabled               = string
#     public_network_access_enabled     = string
#     private_cluster_enabled           = string
#     node_pool_map = map(object({
#       node_address_prefixes = list(string)
#       pod_address_prefixes  = list(string)
#       name                  = string
#       Environment           = string
#       min_count             = string
#       max_count             = string
#     }))
#     #aks_log_analytics_workspace_id    = string
#     # subnets_map = map(object({
#     #   address_prefixes        = list(string)
#     #   service_delegation_name = optional(string)
#     #   actions                 = optional(list(string))
#     #   }
#     #   )
#     # )
#     }
#   )
#   default = {
#     default_node_pool_sku             = "Standard_B2s"
#     log_analytics_workspace_sku       = "PerGB2018"
#     loadBalancer_type                 = "loadBalancer"
#     location                          = "eastus"
#     rg                                = "my_aks_rg"
#     nodes_rg                          = "my_nodes_rg"
#     name                              = "aks-cluster-name"
#     vnet_name                         = "aks-cluster-vnet"
#     dns_prefix                        = "aks-cluster-dns"
#     service_cidr                      = "10.255.0.0/16"
#     service_dns                       = "10.255.0.4"
#     vnet_cidr                         = "10.0.0.0/16"
#     default_node_pool_zones           = [1, 2, 3]
#     default_node_pool_name            = "default"
#     default_node_pool_os_disk_size_gb = 30
#     default_node_pool_min_count       = 1
#     default_node_pool_max_count       = 3
#     default_node_pool_max_pods        = 32
#     run_command_enabled               = false # Best Practice for Prodcution Servers
#     public_network_access_enabled     = false # Best Practice Default
#     private_cluster_enabled           = true  # Best Practice Default
#     #aks_log_analytics_workspace_id    = null
#     node_pool_map = {
#       aks_default_pool = {
#         node_address_prefixes = ["10.0.124.0/27"]
#         pod_address_prefixes  = ["10.0.132.0/22"]
#         name                  = "pool1"
#         Environment           = "Pool1Tag"
#         min_count             = 1
#         max_count             = 3
#       }
#       node_pool_1 = {
#         node_address_prefixes = ["10.0.124.0/27"]
#         pod_address_prefixes  = ["10.0.132.0/22"]
#         name                  = "pool1"
#         Environment           = "Pool1Tag"
#         min_count             = 1
#         max_count             = 3
#         },
#       node_pool_2 = {
#         node_address_prefixes = ["10.0.124.32/27"]
#         pod_address_prefixes  = ["10.0.136.0/22"]
#         name                  = "pool2"
#         Environment           = "Pool2Tag"
#         min_count             = 1
#         max_count             = 3
#         }
#     }
#     # subnets_map = {                                                             # This could move out of the config.
#     #   aks_default_pool = {
#     #     address_prefixes        = ["10.0.1.0/24"]                               # after subnets_map[x].address_prefixes is freed up.
#     #     service_delegation_name = null                                          # But rem to define default node pool separately!
#     #     actions                 = null                                          # it doesn't need the same service delegation.
#     #   },                                                                        # Now, instead of subnets_map, we need
#     #   aks_firewall_subnet = {                                                   # node_pool_map.node_address_prefixes[x]
#     #     address_prefixes        = ["10.0.0.0/24"]                               # and node_pool_map.pod_address_prefixes.
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"  # Therefore, we need a single subnet definition for
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]     # the default_node_pool, and another for it's pod pool.
#     #   },                                                                        # And then we'll need a for-each to go over
#     #   aks_backend_service_subnet = {                                            # the nodes. And another for each of the node's pods.
#     #     address_prefixes        = ["10.0.2.0/24"]
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]
#     #   },
#     #   aks_node_subnet_1 = {
#     #     address_prefixes        = ["10.0.124.0/27"]
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]
#     #   },
#     #   aks_node_subnet_2 = {
#     #     address_prefixes        = ["10.0.124.32/27"]
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]
#     #   },
#     #   aks_default_pod_pool = {
#     #     address_prefixes        = ["10.0.128.0/22"]
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]
#     #   },
#     #   aks_pod_subnet_1 = {
#     #     address_prefixes        = ["10.0.132.0/22"]
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]
#     #   },
#     #   aks_pod_subnet_2 = {
#     #     address_prefixes        = ["10.0.136.0/22"]
#     #     service_delegation_name = "Microsoft.ContainerService/managedClusters"
#     #     actions                 = ["Microsoft.Network/networkinterfaces/*"]
#     #   },
#     # }
#   }
# }
