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
