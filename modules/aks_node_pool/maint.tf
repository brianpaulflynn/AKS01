resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vnet_subnet_id        = var.vnet_subnet_id
  pod_subnet_id         = var.pod_subnet_id

  enable_auto_scaling = var.node_pool.enable_auto_scaling
  name                = var.node_pool.name
  vm_size             = var.node_pool.vm_size
  os_disk_size_gb     = var.node_pool.os_disk_size_gb
  zones               = var.node_pool.zones
  min_count           = var.node_pool.min_count
  max_count           = var.node_pool.max_count
  max_pods            = var.node_pool.max_pods
  tags = {
    Environment = var.node_pool.Environment
  }
}