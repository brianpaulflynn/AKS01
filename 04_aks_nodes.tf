# # Suggestion: Define Availability Sets for node_pools to improve resiliency.
# resource "azurerm_kubernetes_cluster_node_pool" "node_pool_1" {
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
#   vnet_subnet_id        = azurerm_subnet.aks_subnets["aks_node_subnet_1"].id
#   pod_subnet_id         = azurerm_subnet.aks_subnets["aks_pod_subnet_1"].id
#   enable_auto_scaling   = true
#   # Configurable by module
#   name                  = "pool1"
#   vm_size               = "Standard_B2s"
#   os_disk_size_gb       = 30
#   zones                 = [ 1 , 2 , 3 ]
#   min_count             = 1
#   max_count             = 3
#   max_pods              = 32
#   tags = {
#     Environment         = "Pool1Tag"
#   }
# }

# resource "azurerm_kubernetes_cluster_node_pool" "node_pool_2" {
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
#   vnet_subnet_id        = azurerm_subnet.aks_subnets["aks_node_subnet_2"].id
#   pod_subnet_id         = azurerm_subnet.aks_subnets["aks_pod_subnet_2"].id
#   enable_auto_scaling   = true
#   # Configurable by module
#   name                  = "pool2"
#   vm_size               = "Standard_B2s"
#   os_disk_size_gb       = 30
#   zones                 = [ 1 , 2 , 3 ]
#   min_count             = 1
#   max_count             = 3
#   max_pods              = 32
#   tags = {
#     Environment         = "Pool2Tag"
#   }
# }
