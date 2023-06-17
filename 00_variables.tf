# Define the virtual network and subnets for AKS
variable "my_service_cidr" {
    type = string
    default = "10.255.0.0/16"
}
variable "my_service_dns" {
    type = string
    default = "10.255.0.4"
}
variable   "dns_prefix" { 
    type = string 
    default = "aks-cluster" 
}
variable   "cluster_name" {
    type = string  
    default = "aks_cluster" 
}
variable   "resource_group_name" { 
    type = string 
    default = "aks_cluster_rg" 
}
variable   "node_resource_group" { 
    type = string 
    default = "aks_cluster_nodes_rg" 
}

