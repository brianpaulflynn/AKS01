variable "aks_cluster_default_node_pool_sku" {
    type = string
    default = "Standard_B2s"
}
variable "log_analytics_workspace_sku" {
    type = string
    default = "PerGB2018"
}
variable "aks_loadBalancer_type" {
    type = string
    default = "loadBalancer"
}
variable "aks_location" {
    type = string
    default = "eastus"
}
variable "aks_cluster_rg" { 
    type = string 
    default = "aks_cluster_rg" 
}
variable "aks_nodes_rg" { 
    type = string 
    default = "aks_cluster_nodes_rg" 
}
variable "aks_cluster_name" {
    type = string  
    default = "aks-cluster" 
}
variable "aks_cluster_vnet_name" {
    type = string
    default = "aks-cluster-vnet"
}
variable "aks_cluster_dns_prefix" { 
    type = string 
    default = "aks-cluster-dns" 
}
variable "aks_cluster_service_cidr" {
    type = string
    default = "10.255.0.0/16"
}
variable "aks_cluster_service_dns" {
    type = string
    default = "10.255.0.4"
}
variable "aks_cluster_vnet_cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "subnets_map" {
    type =  map(    object( {   
                        address_prefixes        = list(string)
                        service_delegation_name = optional(string)
                        actions                 = optional(list(string))
                        }
                    )
            )
    default = {
        aks_firewall_subnet = {   
            address_prefixes   = ["10.0.0.0/24"]
            service_delegation_name = "Microsoft.ContainerService/managedClusters"
            actions = [ "Microsoft.Network/networkinterfaces/*" ]
        } ,
        aks_default_node_pool = {
            address_prefixes   = ["10.0.1.0/24"]
            service_delegation_name = null
            actions = null
        } ,
        aks_backend_service_subnet = {
            address_prefixes   = ["10.0.2.0/24"]
            service_delegation_name = "Microsoft.ContainerService/managedClusters"
            actions = [ "Microsoft.Network/networkinterfaces/*" ]
        } ,
        aks_node_subnet_1 = {
            address_prefixes   = ["10.0.124.0/27"]
            service_delegation_name = "Microsoft.ContainerService/managedClusters"
            actions = [ "Microsoft.Network/networkinterfaces/*" ]
        } ,
        aks_node_subnet_2 = {
            address_prefixes   = ["10.0.124.32/27"]
            service_delegation_name = "Microsoft.ContainerService/managedClusters"
            actions = [ "Microsoft.Network/networkinterfaces/*" ]
        } ,
        aks_default_pod_pool = {
            address_prefixes   = ["10.0.128.0/22"]
            service_delegation_name = null
            actions = null
        } ,
        aks_pod_subnet_1 = {
            address_prefixes   = ["10.0.132.0/22"]
            service_delegation_name = "Microsoft.ContainerService/managedClusters"
            actions = [ "Microsoft.Network/networkinterfaces/*" ]
        } ,
        aks_pod_subnet_2 = {
            address_prefixes   = ["10.0.136.0/22"]
            service_delegation_name = "Microsoft.ContainerService/managedClusters"
            actions = [ "Microsoft.Network/networkinterfaces/*" ]
        } ,
    }
}
