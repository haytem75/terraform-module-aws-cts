region            = "us-west-2"
FWsubnetID        = "subnet-004ce8241e95453cb"
subnet1ID         = "subnet-0e4fdedc5163b280a"
subnet2ID         = "subnet-026a04673ec566b1f"
VPCID             = "vpc-00894d0913afc0c53"
IGWID             = "igw-000361501b4d8e794"
PublicRoutTableID = "rtb-030e8646213aaa644"



services = {
  "apache2.ip-10-0-141-17.dc1" = {
    id              = "apache2"
    name            = "apache2"
    kind            = ""
    address         = "10.0.141.17"
    port            = 80
    meta            = {}
    tags            = ["web1"]
    namespace       = ""
    status          = "passing"
    node            = "ip-10-0-141-17"
    node_id         = "a6717e2a-5b83-9e66-9580-bbe7bc4270e0"
    node_address    = "10.0.141.17"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan      = "10.0.141.17"
      lan_ipv4 = "10.0.141.17"
      wan      = "35.87.124.2"
      wan_ipv4 = "35.87.124.2"
    }
    node_meta = {
      consul-network-segment = ""
    }
    cts_user_defined_meta = {}
  },
  "apache2.ip-10-0-74-232.dc1" = {
    id              = "apache2"
    name            = "apache2"
    kind            = ""
    address         = "10.0.74.232"
    port            = 80
    meta            = {}
    tags            = ["web2"]
    namespace       = ""
    status          = "passing"
    node            = "ip-10-0-74-232"
    node_id         = "731e86b6-7983-a90f-d27a-22eb7a50d50a"
    node_address    = "10.0.74.232"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan      = "10.0.74.232"
      lan_ipv4 = "10.0.74.232"
      wan      = "52.33.100.118"
      wan_ipv4 = "52.33.100.118"
    }
    node_meta = {
      consul-network-segment = ""
    }
    cts_user_defined_meta = {}
  },
  "apache2.ip-10-0-74-160.dc1" = {
    id              = "apache2"
    name            = "apache2"
    kind            = ""
    address         = "10.0.74.160"
    port            = 80
    meta            = {}
    tags            = ["web3"]
    namespace       = ""
    status          = "passing"
    node            = "ip-10-0-74-160"
    node_id         = "45b653ac-5g3h-45a5-22fd-22eb7a50cd12"
    node_address    = "10.0.74.160"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan      = "10.0.74.160"
      lan_ipv4 = "10.0.74.160"
      wan      = "52.34.128.100"
      wan_ipv4 = "52.34.128.100"
    }
    node_meta = {
      consul-network-segment = ""
    }
    cts_user_defined_meta = {}
  },
}
