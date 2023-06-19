resource "azurerm_kubernetes_cluster" "aks_cluster" {
  # Locked In / Non-Configurable
  identity {                                          # Managed Identity
    type                            = "UserAssigned"
    identity_ids                    = var.aks_managed_identity_ids
  }
  oms_agent {                                         # Container Insights
    msi_auth_for_monitoring_enabled = true
    log_analytics_workspace_id      = var.aks_log_analytics_workspace_id
  }
  microsoft_defender {                                # Defender
    log_analytics_workspace_id      = var.aks_log_analytics_workspace_id
  }
  network_profile {                                   # CNI Networking
    network_plugin                  = "azure"         # ...
    network_policy                  = "azure"         # Not Calico
    outbound_type                   = var.aks_config.loadBalancer_type
    service_cidr                    = var.aks_config.service_cidr
    dns_service_ip                  = var.aks_config.service_dns
  }
  azure_policy_enabled              = true            # Best Practice
  open_service_mesh_enabled         = true            # Best Practice
  local_account_disabled            = true            # Best Practice. And required by AAD integration.
  #role_based_access_control_enabled = true           # does this conflict with azure_rbac_enabled?
  azure_active_directory_role_based_access_control {  # AAD interated
     managed                        = true
     azure_rbac_enabled             = true            # with RBAC permissions granularity
     admin_group_object_ids         = [ var.AD_GROUP_ID ]  
  }                                                   # for some AAD group identifier
  # ingress_application_gateway{
  #   gateway_id    - (Optional) The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. See this page for further details.
  #   subnet_id     - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  #   #gateway_name - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  #   #subnet_cidr  - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  # }
  # api_server_access_profile {
  #   vnet_integration_enabled  = true # - (Optional) Should API Server VNet Integration be enabled? For more details please visit Use API Server VNet Integration.
  #   subnet_id                 = azurerm_subnet.backend_service_subnet.id #(Optional) The ID of the Subnet where the API server endpoint is delegated to.
  #   #authorized_ip_ranges - (Optional) Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].
  # }
  #   workload_autoscaler_profile {                       # Keda autoscaler
  #   keda_enabled                    = true
  #   vertical_pod_autoscaler_enabled = true
  # }
  default_node_pool {
    # Locked In / Non-Configurable
    vnet_subnet_id                  = var.subnet_ids["aks_default_node_pool"]
    pod_subnet_id                   = var.subnet_ids["aks_default_pod_pool"]
    only_critical_addons_enabled    = true  # Best Practice
    enable_auto_scaling             = true  # Scale for cost savings
    # # Configurable by module
    zones                           = var.aks_config.default_node_pool_zones # [ 1 , 2 , 3 ]   # Use all 3 AZ for max SLA
    vm_size                         = var.aks_config.default_node_pool_sku
    name                            = var.aks_config.default_node_pool_name #"default"
    os_disk_size_gb                 = var.aks_config.default_node_pool_os_disk_size_gb  #= 30
    min_count                       = var.aks_config.default_node_pool_min_count  #= 1
    max_count                       = var.aks_config.default_node_pool_max_count        #= 3
    max_pods                        = var.aks_config.default_node_pool_max_pods         #= 32
  }
  # Configurable by module
  location                          = var.aks_config.location
  resource_group_name               = var.aks_config.rg
  name                              = var.aks_config.name
  node_resource_group               = var.aks_config.nodes_rg
  dns_prefix                        = var.aks_config.dns_prefix
  run_command_enabled               = var.aks_config.run_command_enabled # false # Best Practice for Prodcution Servers
  public_network_access_enabled     = var.aks_config.public_network_access_enabled # false # Best Practice Default
  private_cluster_enabled           = var.aks_config.private_cluster_enabled # true  # Best Practice Default
}