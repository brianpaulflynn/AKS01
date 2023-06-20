variable "aks_location" {
    type = string
    default = "eastus"
}
variable   "aks_cluster_rg" { 
    type = string 
    default = "aks_cluster_rg" 
}
variable   "aks_nodes_rg" { 
    type = string 
    default = "aks_cluster_nodes_rg" 
}
variable   "aks_cluster_name" {
    type = string  
    default = "aks-cluster" 
}
variable "aks_cluster_vnet_name" {
    type = string
    default = "aks-cluster-vnet"
}
variable   "aks_cluster_dns_prefix" { 
    type = string 
    default = "aks-cluster-dns" 
}
variable "aks_cluster_vnet_cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "aks_cluster_service_cidr" {
    type = string
    default = "10.255.0.0/16"
}
variable "aks_cluster_service_dns" {
    type = string
    default = "10.255.0.4"
}
variable "aks_cluster_default_node_pool_sku" {
    type = string
    default = "Standard_B2s"
}
variable "log_analytics_workspace_sku" {
    type = string
    default = "PerGB2018"
}
