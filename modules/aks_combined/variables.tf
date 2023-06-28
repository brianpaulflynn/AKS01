# Env vars
variable "AD_GROUP_ID" { type = string }
# dependencies
variable "aks_managed_identity_ids" { type = list(string) }
variable "aks_log_analytics_workspace_id" { type = string }
# aks config
variable "aks_config" {
  type = object({
    log_analytics_workspace_sku   = string
    loadBalancer_type             = string
    location                      = string
    rg                            = string
    nodes_rg                      = string
    name                          = string
    vnet_name                     = string
    dns_prefix                    = string
    service_cidr                  = string
    service_dns                   = string
    vnet_cidr                     = string
    run_command_enabled           = string
    public_network_access_enabled = string
    private_cluster_enabled       = string
    node_pool_map = map(object({
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
    }))
  })
}

