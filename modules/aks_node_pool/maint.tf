resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vnet_subnet_id        = var.vnet_subnet_id
  pod_subnet_id         = var.pod_subnet_id

  enable_auto_scaling = var.enable_auto_scaling
  name                = var.name
  vm_size             = var.vm_size
  os_disk_size_gb     = var.os_disk_size_gb
  zones               = var.zones
  min_count           = var.min_count
  max_count           = var.max_count
  max_pods            = var.max_pods
  tags = {
    Environment = var.Environment
  }
}