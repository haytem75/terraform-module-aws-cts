terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.30.0"
    }
  }
}

provider "aws" {
    region = var.region
}

data "aws_subnet" "firewallsubnet" {
  id = var.FWsubnetID
}

data "aws_subnet" "subnet1ID" {
  id = var.subnet1ID
}

data "aws_subnet" "subnet2ID" {
  id = var.subnet2ID
}


####### Firewall Rule Group
resource "aws_networkfirewall_rule_group" "CTS-RG" {
  capacity = 10
  name     = "CTS-Rule-Group"
  type     = "STATEFUL"

  rule_group {
      stateful_rule_options {
        rule_order = "STRICT_ORDER"
      }
      rule_variables {
        ip_sets {
          key = "WEBSERVERS_HOSTS"
          ip_set {
            definition = [for i in var.services : join("/",[values(i).0,"32"])]
#           definition = ["${data.aws_subnet.firewallsubnet.cidr_block}","${data.aws_subnet.subnet1ID.cidr_block}"]
          }
        }
        ip_sets {
          key = "PREEXISTING_ENV"
          ip_set {
            definition = ["10.0.73.25/32","34.213.182.95","10.0.139.60/32"]
          }
        }
      }

    rules_source {
       rules_string = <<EOF
       pass ip 10.0.0.0/8 any -> any any (sid:10;)
       pass ip any any -> $PREEXISTING_ENV any (sid:20;)
       pass ip any any -> $WEBSERVERS_HOSTS any (sid:30;)
       drop ip any any -> any any (sid:40;)
      EOF

      /* stateful_rule {
        action = "DROP" 
        header {
            protocol            = "IP" 
            source              = "ANY"
            destination         = "ANY"
            source_port         = "ANY" 
            destination_port    = "ANY"
            direction           = "FORWARD"
 
        }
        rule_option {
            keyword    = "sid:25"
        }
      }  
      stateful_rule {
        action = "PASS" 
        header {
            protocol            = "IP" 
            source              = "10.0.0.0/8"
            destination         = "ANY"
            source_port         = "ANY" 
            destination_port    = "ANY"
            direction           = "FORWARD"
 
        }
        rule_option {
            keyword    = "sid:10"
        }
      }
      stateful_rule {
        action = "PASS" 
        header {
            protocol            = "IP" 
            source              = "ANY"
            destination         = "$PREEXISTING_ENV"
            source_port         = "ANY" 
            destination_port    = "ANY"
            direction           = "FORWARD"
 
        }
        rule_option {
            keyword    = "sid:15"
        }
      }
      stateful_rule {
        action = "PASS" 
        header {
            protocol            = "IP" 
            source              = "ANY"
            destination         = "$WEBSERVERS_HOSTS"
            source_port         = "ANY" 
            destination_port    = "ANY"
            direction           = "FORWARD"
 
        }
        rule_option {
            keyword    = "sid:20"
        }
      }     */
    }
  }
  tags = {
    Name = "CTS-FW-RuleGroup"
  }
}


####### Firewall Policy
resource "aws_networkfirewall_firewall_policy" "CTS-FW-Policy" {
  name = "CTS-FW-Policy"
  depends_on = [aws_networkfirewall_rule_group.CTS-RG]
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
        rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
        priority = 100
        resource_arn = aws_networkfirewall_rule_group.CTS-RG.arn
    }

  }
  tags = {
    Name = "CTS_FW_Policy"
  }
}


#### Create Firwall in the specified subnet
resource "aws_networkfirewall_firewall" "CTS-FW" {
  name                = "CTS-FW"
  depends_on = [aws_networkfirewall_firewall_policy.CTS-FW-Policy]
  firewall_policy_arn = aws_networkfirewall_firewall_policy.CTS-FW-Policy.arn
  vpc_id              = var.VPCID
  subnet_mapping {
    subnet_id = var.FWsubnetID
  }
  delete_protection = false
  subnet_change_protection = false

  tags = {
    Name = "CTS FW"
  }
}


###### create a vpc endpoint for routing to the firewall
data "aws_vpc_endpoint" "firewallep" {
  vpc_id       = var.VPCID

  tags = {
    "AWSNetworkFirewallManaged" = "true"
    "Firewall" = aws_networkfirewall_firewall.CTS-FW.arn
  }
  depends_on = [aws_networkfirewall_firewall.CTS-FW]
}

### Creating a route table to route from IGW to the firewall
resource "aws_route_table" "IGW-RT" {
  vpc_id       = var.VPCID

# routing to all existing subnets
  route { 
    cidr_block = "10.0.128.0/20"
    vpc_endpoint_id = data.aws_vpc_endpoint.firewallep.id
  }
    route {
    cidr_block = "10.0.64.0/20"
    vpc_endpoint_id = data.aws_vpc_endpoint.firewallep.id
  }
    route {
    cidr_block = "10.0.32.0/20"
    vpc_endpoint_id = data.aws_vpc_endpoint.firewallep.id
  }
  tags       = {
    Name     = "IGW ingress routing to firewall"
  }
}

########## associate IGW to the route table
resource "aws_route_table_association" "IGWtoFW" {
  gateway_id     = var.IGWID
  route_table_id = aws_route_table.IGW-RT.id
}

######### Create a FW route table for egress default route to IGW
resource "aws_route_table" "FWtoIGW" {
  vpc_id       = var.VPCID

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.IGWID
  }
  tags       = {
    Name     = "FW egress routing"
  }
}

### FW route table association to FW subnet
resource "aws_route_table_association" "FWtoIGW" {
  subnet_id     = var.FWsubnetID
  route_table_id = aws_route_table.FWtoIGW.id
}

### change public route 
/* resource "aws_route" "publicroute" {
  route_table_id            = var.PublicRoutTableID
  destination_cidr_block    = "0.0.0.0/0"
  vpc_endpoint_id           = data.aws_vpc_endpoint.firewallep.id
} */


output "firewall-rg-arn" {
  value = aws_networkfirewall_rule_group.CTS-RG.arn
}
