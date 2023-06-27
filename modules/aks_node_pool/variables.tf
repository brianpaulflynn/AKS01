variable "kubernetes_cluster_id" { type = string }
variable "vnet_subnet_id" { type = string }
variable "pod_subnet_id" { type = string }
# add node_pool type def
variable "enable_auto_scaling" { type = bool }
variable "name" { type = string }
variable "vm_size" { type = string }
variable "os_disk_size_gb" { type = number }
variable "zones" { type = list(string) }
variable "min_count" { type = string }
variable "max_count" { type = string }
variable "max_pods" { type = string }
variable "Environment" { type = string }
