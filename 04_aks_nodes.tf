# Suggestion: Define Availability Sets for node_pools to improve resiliency.
resource "azurerm_kubernetes_cluster_node_pool" "node_pool_1" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vnet_subnet_id        = azurerm_subnet.node_subnet_1.id
  pod_subnet_id         = azurerm_subnet.pod_subnet_1.id
  name                  = "pool1"
  vm_size               = "Standard_B2s"
  zones                 = [ 1 , 2 , 3 ]
  min_count             = 1
  max_count             = 3
  max_pods              = 32
  os_disk_size_gb       = 30
  enable_auto_scaling   = true
  tags = {
    Environment         = "Pool1Tag"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pool_2" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vnet_subnet_id        = azurerm_subnet.node_subnet_2.id
  pod_subnet_id         = azurerm_subnet.pod_subnet_2.id
  name                  = "pool2"
  vm_size               = "Standard_B2s"
  zones                 = [ 1 , 2 , 3 ]
  min_count             = 1
  max_count             = 3
  max_pods              = 32
  os_disk_size_gb       = 30
  enable_auto_scaling   = true
  tags = {
    Environment         = "Pool2Tag"
  }
}
