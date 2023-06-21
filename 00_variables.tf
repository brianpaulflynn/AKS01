variable "aks_config" {
    type    =   object({
                        aks_cluster_default_node_pool_sku   = string
                        log_analytics_workspace_sku         = string
                        aks_loadBalancer_type               = string
                        aks_location                        = string
                        aks_cluster_rg                      = string
                        aks_nodes_rg                        = string
                        aks_cluster_name                    = string
                        aks_cluster_vnet_name               = string
                        aks_cluster_dns_prefix              = string
                        aks_cluster_service_cidr            = string
                        aks_cluster_service_dns             = string
                        aks_cluster_vnet_cidr               = string
                        subnets_map =   map(    object( {   
                                                    address_prefixes        = list(string)
                                                    service_delegation_name = optional(string)
                                                    actions                 = optional(list(string))
                                                    }
                                                )
                                            )
                        }
                    )
    default =   {
        aks_cluster_default_node_pool_sku   = "Standard_B2s"
        log_analytics_workspace_sku         = "PerGB2018"
        aks_loadBalancer_type               = "loadBalancer"
        aks_location                        = "eastus"
        aks_cluster_rg                      = "aks_cluster_rg"
        aks_nodes_rg                        = "aks_cluster_nodes_rg"
        aks_cluster_name                    = "aks-cluster-name"
        aks_cluster_vnet_name               = "aks-cluster-vnet"
        aks_cluster_dns_prefix              = "aks-cluster-dns"
        aks_cluster_service_cidr            = "10.255.0.0/16"
        aks_cluster_service_dns             = "10.255.0.4"
        aks_cluster_vnet_cidr               = "10.0.0.0/16"
        subnets_map = {
            aks_default_node_pool = {
                address_prefixes        = ["10.0.1.0/24"]
                service_delegation_name = null
                actions                 = null
            } ,
            aks_firewall_subnet = {   
                address_prefixes        = ["10.0.0.0/24"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
            aks_backend_service_subnet = {
                address_prefixes        = ["10.0.2.0/24"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
            aks_node_subnet_1 = {
                address_prefixes        = ["10.0.124.0/27"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
            aks_node_subnet_2 = {
                address_prefixes        = ["10.0.124.32/27"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
            aks_default_pod_pool = {
                address_prefixes        = ["10.0.128.0/22"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
            aks_pod_subnet_1 = {
                address_prefixes        = ["10.0.132.0/22"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
            aks_pod_subnet_2 = {
                address_prefixes        = ["10.0.136.0/22"]
                service_delegation_name = "Microsoft.ContainerService/managedClusters"
                actions                 = [ "Microsoft.Network/networkinterfaces/*" ]
            } ,
        }
    } 
}
