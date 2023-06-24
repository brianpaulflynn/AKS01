variable "resource_group_name" {
    type    = string
}
variable "virtual_network_name" {
    type    = string
}
variable "aks_config" {
    type    =   object( {
                        default_node_pool_sku               = string
                        log_analytics_workspace_sku     = string
                        loadBalancer_type               = string
                        location                        = string
                        rg                                  = string
                        nodes_rg                            = string
                        name                                = string
                        vnet_name                           = string
                        dns_prefix                          = string
                        service_cidr                        = string
                        service_dns                         = string
                        vnet_cidr                           = string
                        default_node_pool_zones            = list(string)
                        default_node_pool_name              = string
                        default_node_pool_os_disk_size_gb   = string
                        default_node_pool_min_count         = string
                        default_node_pool_max_count         = string
                        default_node_pool_max_pods          = string
                        run_command_enabled                 = string
                        public_network_access_enabled       = string
                        private_cluster_enabled             = string
                        aks_log_analytics_workspace_id      = string
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
        default_node_pool_sku               = "Standard_B2s"
        log_analytics_workspace_sku     = "PerGB2018"
        loadBalancer_type               = "loadBalancer"
        location                        = "eastus"
        rg                                  = "my_aks_rg"
        nodes_rg                            = "my_nodes_rg"
        name                                = "aks-cluster-name"
        vnet_name                           = "aks-cluster-vnet"
        dns_prefix                          = "aks-cluster-dns"
        service_cidr                        = "10.255.0.0/16"
        service_dns                         = "10.255.0.4"
        vnet_cidr                           = "10.0.0.0/16"
        default_node_pool_zones             = [ 1 , 2 , 3 ]
        default_node_pool_name              = "default"
        default_node_pool_os_disk_size_gb   = 30
        default_node_pool_min_count         = 1
        default_node_pool_max_count         = 3
        default_node_pool_max_pods          = 32
        run_command_enabled               = false   # Best Practice for Prodcution Servers
        public_network_access_enabled     = false   # Best Practice Default
        private_cluster_enabled           = true    # Best Practice Default
        aks_log_analytics_workspace_id      = null
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