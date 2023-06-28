variable "resource_group_name" { type = string }
variable "network_security_group_name" { type = string }
variable "node_subnet_prefixes" { type = list(string) }
variable "pod_subnet_prefixes" { type = list(string) }

