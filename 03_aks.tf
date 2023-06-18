# Define AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  location                          = azurerm_resource_group.aks_rg.location
  resource_group_name               = azurerm_resource_group.aks_rg.name
  name                              = "aks-cluster"
  dns_prefix                        = "aks-cluster"
  node_resource_group               = "aks_nodes_rg"
  public_network_access_enabled     = false
  run_command_enabled               = false
  private_cluster_enabled           = true
  local_account_disabled            = true
  azure_policy_enabled              = true
  open_service_mesh_enabled         = true
  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
     managed                        = true            # AD Integrated
     azure_rbac_enabled             = true            # with RBAC permissions granularity
     admin_group_object_ids         = ["${var.AD_GROUP_ID}"]  # for some AAD group identifier
  }
  identity {
    type                            = "UserAssigned"  # Managed Identity
    identity_ids                    = [ azurerm_user_assigned_identity.aks_cluster_identity.id ]
  }
  network_profile {
    network_plugin                  = "azure"         # CNI Networking
    network_policy                  = "azure"         # Not Calico
    outbound_type                   = "loadBalancer"
    service_cidr                    = "${var.my_service_cidr}"
    dns_service_ip                  = "${var.my_service_dns}"
  }
  oms_agent {   # "Container Insights"
    msi_auth_for_monitoring_enabled = true
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks_log_analytics.id
  }
  microsoft_defender{
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks_log_analytics.id
  }
  default_node_pool {
    vnet_subnet_id                  = azurerm_subnet.default_node_pool.id
    pod_subnet_id                   = azurerm_subnet.default_pod_pool.id
    name                            = "default"
    vm_size                         = "Standard_B2s"
    zones                           = [ 1 , 2 , 3 ]
    min_count                       = 1
    max_count                       = 3
    max_pods                        = 32
    os_disk_size_gb                 = 30
    only_critical_addons_enabled    = true
    enable_auto_scaling             = true
  }

  # ingress_application_gateway{
  #   gateway_id    - (Optional) The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. See this page for further details.
  #   subnet_id     - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  #   #gateway_name - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  #   #subnet_cidr  - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  # }

  # workload_autoscaler_profile{
  #   keda_enabled                    = true
  #   vertical_pod_autoscaler_enabled = true
  # }

  # api_server_access_profile {
  #   vnet_integration_enabled  = true # - (Optional) Should API Server VNet Integration be enabled? For more details please visit Use API Server VNet Integration.
  #   subnet_id                 = azurerm_subnet.backend_service_subnet.id #(Optional) The ID of the Subnet where the API server endpoint is delegated to.
  #   #authorized_ip_ranges - (Optional) Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].
  # }

}
