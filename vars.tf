
variable "region" {
  type = string
}

variable "FWsubnetID" {
  type = string
  description = "the subnet ID on which the filewall is created and depolying the endpoint"
}

variable "subnet1ID" {
  type = string
  description = "subnet 1 where those servers are created"
}


variable "subnet2ID" {
  type = string
  description = "subnet 2 where those servers are created"
}

variable "VPCID" {
  type = string
  description = "the VPC ID on which these infrastruture is implimented"
}

variable "IGWID" {
  type = string
  description = "internet gateway ID of the VPC for routing configuration of the firewall and Webservers"
}

variable "PublicRoutTableID" {
  type = string
  description = "needed to change default route for the public subnets to firewall VPCendpoints "
}

variable "services" {
  description = "Consul services monitored by Consul-Terraform-Sync"
  type = map(
    object({
      id        = string
      name      = string
      kind      = string
      address   = string
      port      = number
      meta      = map(string)
      tags      = list(string)
      namespace = string
      status    = string
      node                  = string
      node_id               = string
      node_address          = string
      node_datacenter       = string
      node_tagged_addresses = map(string)
      node_meta             = map(string)
cts_user_defined_meta = map(string)
    })
  )
}
