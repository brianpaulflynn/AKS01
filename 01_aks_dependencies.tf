# Define the resource group
resource "azurerm_resource_group" "aks_cluster_rg" {
  name     = var.aks_cluster_rg
  location = var.aks_location
}

# Create Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_log_analytics" {
  location            = azurerm_resource_group.aks_cluster_rg.location
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name
  sku                 = var.log_analytics_workspace_sku
  name                = "${var.aks_cluster_name}-analytics" #"aks-cluster-log-analytics"
}

# Define user assigned identities
resource "azurerm_user_assigned_identity" "aks_cluster_identity" {
  location            = azurerm_resource_group.aks_cluster_rg.location
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name
  name                = "${var.aks_cluster_name}-identity" # "aks-cluster-identity"
}

# # Grant AKS cluster access to use AKS vnet
# resource "azurerm_role_assignment" "aks-cluster-access" {
#   role_definition_name = "Network Contributor"
#   scope                = azurerm_subnet.backend_service_subnet.id
#   principal_id         = azurerm_user_assigned_identity.aks_cluster_identity.principal_id
#  }

 # azurerm_resource_group.aks_cluster_rg.id 
  # data.azurerm_subscription.primary.id
  # azurerm_subnet.backend_service_subnet.id
  #principal_id         = azurerm_user_assigned_identity.aks_cluster_identity.principal_id
  #delegated_managed_identity_resource_id = azurerm_kubernetes_cluster.aks_cluster.id
    # azurerm_kubernetes_cluster.aks_cluster.principal_id
    # azurerm_user_assigned_identity.aks_cluster_identity.id
    # azurerm_user_assigned_identity.aks_cluster_identity.principal_id
    # azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
#  scope                = "/subscriptions/b5d3c617-3046-430c-98e3-2582f594fcaf/resourceGroups/aks-rg/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/aks-backend-service-subnet"
  # azurerm_resource_group.aks_cluster_rg.id
  # data.azurerm_subscription.primary.id
  # azurerm_virtual_network.aks_vnet.id
  # id         = azurerm_user_assigned_identity.aks_cluster_identity.id
  #delegated_managed_identity_resource_id  = azurerm_user_assigned_identity.aks_cluster_identity.id
  # azurerm_virtual_network.aks_vnet.id
    # 
  # azurerm_user_assigned_identity.aks_cluster_identity.id
  #scope                = azurerm_kubernetes_cluster.aks_cluster.id
  # data.azurerm_subscription.primary.id
  #depends_on = [ null_resource.wait_for]
#}

# resource "null_resource" "wait_for" {
#     provisioner "local-exec" {
#       command = "sleep 60"
#     }
#     depends_on = [  azurerm_kubernetes_cluster.aks_cluster, 
#                     azurerm_subnet.backend_service_subnet,
#                     azurerm_user_assigned_identity.aks_cluster_identity
#     ]
# }

/*
Error: authorization.RoleAssignmentsClient#Create: 
Failure responding to request: 
StatusCode=403 -- 
Original Error: 
autorest/azure: 
Service returned an error. 
Status=403 
Code="AuthorizationFailed" 
Message="The client '5c0bb291-a9b2-49c0-b747-cc9a56493bea' 
with object id '5c0bb291-a9b2-49c0-b747-cc9a56493bea' 
does not have authorization or an ABAC condition not fulfilled to perform action 
'Microsoft.Authorization/roleAssignments/write' over scope 
'/subscriptions/b5d3c617-3046-430c-98e3-2582f594fcaf/resourceGroups/aks-rg/
providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/aks-backend-service-subnet/
providers/Microsoft.Authorization/roleAssignments/a3cd0d38-2721-3e56-39dc-f12ff26cb0e6' 
or the scope is invalid. If access was recently granted, please refresh your credentials."
*/


