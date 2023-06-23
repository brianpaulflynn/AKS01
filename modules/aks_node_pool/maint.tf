resource "azurerm_kubernetes_cluster_node_pool" "node_pool_1" {
  kubernetes_cluster_id = var.kubernetes_cluster_id #azurerm_kubernetes_cluster.aks_cluster.id
  vnet_subnet_id        = var.vnet_subnet_id #azurerm_subnet.aks_subnets["aks_node_subnet_1"].id
  pod_subnet_id         = var.pod_subnet_id #azurerm_subnet.aks_subnets["aks_pod_subnet_1"].id
  enable_auto_scaling   = var.enable_auto_scaling #true
  # Configurable by module
  name                  = var.name #"pool1"
  vm_size               = var.vm_size #"Standard_B2s"
  os_disk_size_gb       = var.os_disk_size_gb #30
  zones                 = var.zones #[ 1 , 2 , 3 ]
  min_count             = var.min_count #1
  max_count             = var.max_count #3
  max_pods              = var.max_pods #32
  tags = {
    Environment         = var.Environment # "Pool1Tag"
  }
}