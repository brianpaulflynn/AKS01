variable "subnets_map" {
    type    =   map(   object( {   
                                address_prefixes        = list(string)
                                service_delegation_name = optional(string)
                                actions                 = optional(list(string))
                            }
                        )
                )
  }
variable "subnet_id"    {
    type    =   string
}
variable "network_security_group_id" {
    type    =   string
}
