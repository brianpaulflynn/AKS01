variable "resource_group_name" { type = string }
variable "network_security_group_name" { type = string }
variable "node_subnet_prefixes" { type = list(string) }
variable "pod_subnet_prefixes" { type = list(string) }
# variable "node_pool_map" {
#   type = map(object({
#     node_address_prefixes = list(string)
#     pod_address_prefixes  = list(string)
#     max_pods              = string
#     name                  = string
#     Environment           = string
#     vm_size               = string
#     os_disk_size_gb       = string
#     zones                 = list(number)
#     enable_auto_scaling   = string
#     min_count             = string
#     max_count             = string
#   }))
# }
