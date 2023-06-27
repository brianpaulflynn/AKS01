variable "kubernetes_cluster_id" { type = string }
variable "vnet_subnet_id" { type = string }
variable "pod_subnet_id" { type = string }
variable "node_pool" {
  type = object({
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
  })
}

