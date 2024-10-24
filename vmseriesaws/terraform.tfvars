### GENERAL
region      = "us-east-1" # Ajustar antes do deploy
name_prefix = "lab-"      # Ajustar antes do deploy

global_tags = {
  aplicacao  = "vm-series"
  centro_custo = "suporte"
}

ssh_key_name = "edp" # Ajustar antes do deploy

### VPC
vpcs = {
  # Do not use `-` in key for VPC as this character is used in concatation of VPC and subnet for module `subnet_set` in `main.tf`
  security_vpc = {
    name = "security-vpc"
    cidr = "10.100.0.0/16"
    nacls = {
      trusted_path_monitoring = {
        name = "trusted-path-monitoring"
        rules = {
          block_outbound_icmp_1 = {
            rule_number = 110
            egress      = true
            protocol    = "icmp"
            rule_action = "deny"
            cidr_block  = "10.100.1.0/24"
            from_port   = null
            to_port     = null
          }
          block_outbound_icmp_2 = {
            rule_number = 120
            egress      = true
            protocol    = "icmp"
            rule_action = "deny"
            cidr_block  = "10.100.65.0/24"
            from_port   = null
            to_port     = null
          }
          allow_other_outbound = {
            rule_number = 200
            egress      = true
            protocol    = "-1"
            rule_action = "allow"
            cidr_block  = "0.0.0.0/0"
            from_port   = null
            to_port     = null
          }
          allow_inbound = {
            rule_number = 300
            egress      = false
            protocol    = "-1"
            rule_action = "allow"
            cidr_block  = "0.0.0.0/0"
            from_port   = null
            to_port     = null
          }
        }
      }
    }
    security_groups = {
      lambda = {
        name = "lambda"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          all_inbound = {
            description = "Permit All traffic inbound"
            type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }
      vmseries_private = {
        name = "vmseries_private"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          geneve = {
            description = "Permit GENEVE to GWLB subnets"
            type        = "ingress", from_port = "6081", to_port = "6081", protocol = "udp"
            cidr_blocks = [
              "10.100.5.0/24", "10.100.69.0/24"
            ]
          }
          health_probe = {
            description = "Permit Port 80 Health Probe to GWLB subnets"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = [
              "10.100.5.0/24", "10.100.69.0/24"
            ]
          }
        }
      }
      vmseries_mgmt = {
        name = "vmseries_mgmt"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          https = {
            description = "Permit HTTPS"
            type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
          ssh = {
            description = "Permit SSH"
            type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
          panorama_ssh = {
            description = "Permit Panorama SSH (Optional)"
            type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
          panorama_mgmt = {
            description = "Permit Panorama Management"
            type        = "ingress", from_port = "3978", to_port = "3978", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
          panorama_log = {
            description = "Permit Panorama Logging"
            type        = "ingress", from_port = "28443", to_port = "28443", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
      }
      vmseries_public = {
        name = "vmseries_public"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          ssh = {
            description = "Permit SSH"
            type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0", "10.104.0.0/16", "10.105.0.0/16"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
          https = {
            description = "Permit HTTPS"
            type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0", "10.104.0.0/16", "10.105.0.0/16"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
          http = {
            description = "Permit HTTP"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0", "10.104.0.0/16", "10.105.0.0/16"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
        }
      }
    }
    subnets = {
      # Do not modify value of `set=`, it is an internal identifier referenced by main.tf
      # Value of `nacl` must match key of objects stored in `nacls`
      "10.100.0.0/24"  = { az = "us-east-1a", set = "mgmt", nacl = null }
      "10.100.64.0/24" = { az = "us-east-1b", set = "mgmt", nacl = null }
      "10.100.1.0/24"  = { az = "us-east-1a", set = "private", nacl = "trusted_path_monitoring" }
      "10.100.65.0/24" = { az = "us-east-1b", set = "private", nacl = "trusted_path_monitoring" }
      "10.100.2.0/24"  = { az = "us-east-1a", set = "public", nacl = null }
      "10.100.66.0/24" = { az = "us-east-1b", set = "public", nacl = null }
      "10.100.3.0/24"  = { az = "us-east-1a", set = "tgw_attach", nacl = null }
      "10.100.67.0/24" = { az = "us-east-1b", set = "tgw_attach", nacl = null }
      "10.100.4.0/24"  = { az = "us-east-1a", set = "gwlbe_outbound", nacl = null }
      "10.100.68.0/24" = { az = "us-east-1b", set = "gwlbe_outbound", nacl = null }
      "10.100.5.0/24"  = { az = "us-east-1a", set = "gwlb", nacl = null }
      "10.100.69.0/24" = { az = "us-east-1b", set = "gwlb", nacl = null }
      "10.100.10.0/24" = { az = "us-east-1a", set = "gwlbe_eastwest", nacl = null }
      "10.100.74.0/24" = { az = "us-east-1b", set = "gwlbe_eastwest", nacl = null }
      "10.100.11.0/24" = { az = "us-east-1a", set = "natgw", nacl = null }
      "10.100.75.0/24" = { az = "us-east-1b", set = "natgw", nacl = null }
      "10.100.12.0/24" = { az = "us-east-1a", set = "lambda", nacl = null }
      "10.100.76.0/24" = { az = "us-east-1b", set = "lambda", nacl = null }
    }
    routes = {
      # Value of `vpc_subnet` is built from key of VPCs concatenate with `-` and key of subnet in format: `VPCKEY-SUBNETKEY`
      # Value of `next_hop_key` must match keys use to create TGW attachment, IGW, GWLB endpoint or other resources
      # Value of `next_hop_type` is internet_gateway, nat_gateway, transit_gateway_attachment or gwlbe_endpoint
      mgmt_default = {
        vpc_subnet    = "security_vpc-mgmt"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "security_vpc"
        next_hop_type = "internet_gateway"
      }
  #    mgmt_panorama = {
  #      vpc_subnet    = "security_vpc-mgmt"
  #      to_cidr       = "10.255.0.0/16"
  #      next_hop_key  = "security"
  #      next_hop_type = "transit_gateway_attachment"
  #    }
      mgmt_rfc1918 = {
        vpc_subnet    = "security_vpc-mgmt"
        to_cidr       = "10.0.0.0/8"
        next_hop_key  = "security"
        next_hop_type = "transit_gateway_attachment"
      }
      lambda_default = {
        vpc_subnet    = "security_vpc-lambda"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "security_nat_gw"
        next_hop_type = "nat_gateway"
      }
      lambda_panorama = {
        vpc_subnet    = "security_vpc-lambda"
        to_cidr       = "10.255.0.0/16"
        next_hop_key  = "security"
        next_hop_type = "transit_gateway_attachment"
      }
      lambda_rfc1918 = {
        vpc_subnet    = "security_vpc-lambda"
        to_cidr       = "10.0.0.0/8"
        next_hop_key  = "security"
        next_hop_type = "transit_gateway_attachment"
      }
      tgw_rfc1918 = {
        vpc_subnet    = "security_vpc-tgw_attach"
        to_cidr       = "10.0.0.0/8"
        next_hop_key  = "security_gwlb_eastwest"
        next_hop_type = "gwlbe_endpoint"
      }
      tgw_default = {
        vpc_subnet    = "security_vpc-tgw_attach"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "security_gwlb_outbound"
        next_hop_type = "gwlbe_endpoint"
      }
      public_default = {
        vpc_subnet    = "security_vpc-public"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "security_nat_gw"
        next_hop_type = "nat_gateway"
      }
      gwlbe_outbound_rfc1918 = {
        vpc_subnet    = "security_vpc-gwlbe_outbound"
        to_cidr       = "10.0.0.0/8"
        next_hop_key  = "security"
        next_hop_type = "transit_gateway_attachment"
      }
  #    gwlbe_eastwest_rfc1918 = {
  #      vpc_subnet    = "security_vpc-gwlbe_eastwest"
  #      to_cidr       = "10.0.0.0/8"
  #      next_hop_key  = "security"
  #      next_hop_type = "transit_gateway_attachment"
  #    }
      nat_default = {
        vpc_subnet    = "security_vpc-natgw"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "security_vpc"
        next_hop_type = "internet_gateway"
      }
      nat_rfc1918 = {
        vpc_subnet    = "security_vpc-natgw"
        to_cidr       = "10.0.0.0/8"
        next_hop_key  = "security_gwlb_outbound"
        next_hop_type = "gwlbe_endpoint"
      }
    }
  }
  app1_vpc = {
    name  = "app1-spoke-vpc"
    cidr  = "10.104.0.0/16"
    nacls = {}
    security_groups = {
      app1_vm = {
        name = "app1_vm"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          ssh = {
            description = "Permit SSH"
            type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0", "10.104.0.0/16", "10.105.0.0/16"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
          https = {
            description = "Permit HTTPS"
            type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0", "10.104.0.0/16", "10.105.0.0/16"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
          http = {
            description = "Permit HTTP"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0", "10.104.0.0/16", "10.105.0.0/16"] # Ajustar antes do deploy (replace 0.0.0.0/0 by your IP range)
          }
        }
      }
    }
    subnets = {
      # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
      "10.104.0.0/24"   = { az = "us-east-1a", set = "app1_vm", nacl = null }
      "10.104.128.0/24" = { az = "us-east-1b", set = "app1_vm", nacl = null }
      "10.104.2.0/24"   = { az = "us-east-1a", set = "app1_lb", nacl = null }
      "10.104.130.0/24" = { az = "us-east-1b", set = "app1_lb", nacl = null }
      "10.104.3.0/24"   = { az = "us-east-1a", set = "app1_gwlbe", nacl = null }
      "10.104.131.0/24" = { az = "us-east-1b", set = "app1_gwlbe", nacl = null }
    }
    routes = {
      # Value of `vpc_subnet` is built from key of VPCs concatenate with `-` and key of subnet in format: `VPCKEY-SUBNETKEY`
      # Value of `next_hop_key` must match keys use to create TGW attachment, IGW, GWLB endpoint or other resources
      # Value of `next_hop_type` is internet_gateway, nat_gateway, transit_gateway_attachment or gwlbe_endpoint
      vm_default = {
        vpc_subnet    = "app1_vpc-app1_vm"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "app1"
        next_hop_type = "transit_gateway_attachment"
      }
      gwlbe_default = {
        vpc_subnet    = "app1_vpc-app1_gwlbe"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "app1_vpc"
        next_hop_type = "internet_gateway"
      }
      lb_default = {
        vpc_subnet    = "app1_vpc-app1_lb"
        to_cidr       = "0.0.0.0/0"
        next_hop_key  = "app1_inbound"
        next_hop_type = "gwlbe_endpoint"
      }
    }
  }
}

### TRANSIT GATEWAY
tgw = {
  create = true
  id     = null
  name   = "tgw"
  asn    = "64550"
  route_tables = {
    # Do not change keys `from_security_vpc` and `from_spoke_vpc` as they are used in `main.tf` and attachments
    "from_security_vpc" = {
      create = true
      name   = "from_security"
    }
    "from_spoke_vpc" = {
      create = true
      name   = "from_spokes"
    }
  }
  attachments = {
    # Value of `vpc_subnet` is built from key of VPCs concatenate with `-` and key of subnet in format: `VPCKEY-SUBNETKEY`
    # Value of `route_table` and `propagate_routes_to` must match `route_tables` stores under `tgw`
    security = {
      name                = "vmseries"
      vpc_subnet          = "security_vpc-tgw_attach"
      route_table         = "from_security_vpc"
      propagate_routes_to = "from_spoke_vpc"
    }
    app1 = {
      name                = "app1-spoke-vpc"
      vpc_subnet          = "app1_vpc-app1_vm"
      route_table         = "from_spoke_vpc"
      propagate_routes_to = "from_security_vpc"
    }
  }
}

### NAT GATEWAY
natgws = {
  # Value of `vpc_subnet` is built from key of VPCs concatenate with `-` and key of subnet in format: `VPCKEY-SUBNETKEY`
  security_nat_gw = {
    name       = "natgw"
    vpc_subnet = "security_vpc-natgw"
  }
}

### GATEWAY LOADBALANCER
gwlbs = {
  # Value of `vpc_subnet` is built from key of VPCs concatenate with `-` and key of subnet in format: `VPCKEY-SUBNETKEY`
  security_gwlb = {
    name       = "security-gwlb"
    vpc_subnet = "security_vpc-gwlb"
  }
}
gwlb_endpoints = {
  # Value of `gwlb` must match key of objects stored in `gwlbs`
  # Value of `vpc` must match key of objects stored in `vpcs`
  # Value of `vpc_subnet` is built from key of VPCs concatenate with `-` and key of subnet in format: `VPCKEY-SUBNETKEY`
  security_gwlb_eastwest = {
    name            = "eastwest-gwlb-endpoint"
    gwlb            = "security_gwlb"
    vpc             = "security_vpc"
    vpc_subnet      = "security_vpc-gwlbe_eastwest"
    act_as_next_hop = false
    to_vpc_subnets  = null
  }
  security_gwlb_outbound = {
    name            = "outbound-gwlb-endpoint"
    gwlb            = "security_gwlb"
    vpc             = "security_vpc"
    vpc_subnet      = "security_vpc-gwlbe_outbound"
    act_as_next_hop = false
    to_vpc_subnets  = null
  }
  app1_inbound = {
    name            = "app1-gwlb-endpoint"
    gwlb            = "security_gwlb"
    vpc             = "app1_vpc"
    vpc_subnet      = "app1_vpc-app1_gwlbe"
    act_as_next_hop = true
    to_vpc_subnets  = "app1_vpc-app1_lb"
  }
}

### VM-SERIES
vmseries_asgs = {
  main_asg = {
    # Value of `panorama-server`, `auth-key`, `dgname`, `tplname` can be taken from plugin `sw_fw_license`
    bootstrap_options = {
      mgmt-interface-swap         = "enable"
      plugin-op-commands          = "aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable" # Ajustar antes do deploy
      panorama-server             = "10.10.0.61"                                              # Ajustar antes do deploy
      authcodes                   = "D8310737" 
      vm-auth-key                 = "396026836516613"                                         # Ajustar antes do deploy
      dgname                      = "dgname"                                                  # Ajustar antes do deploy
      tplname                     = "tplname-stack"                                           # Ajustar antes do deploy
      dhcp-send-hostname          = "yes"                                                     # Ajustar antes do deploy
      dhcp-send-client-id         = "yes"                                                     # Ajustar antes do deploy
      dhcp-accept-server-hostname = "yes"                                                     # Ajustar antes do deploy
      dhcp-accept-server-domain   = "yes"                                                     # Ajustar antes do deploy
    }

    panos_version = "11.1.2-h3"        # Ajustar antes do deploy
    ebs_kms_id    = "alias/aws/ebs" # Ajustar antes do deploy

    # Value of `vpc` must match key of objects stored in `vpcs`
    vpc = "security_vpc"

    # Value of `gwlb` must match key of objects stored in `gwlbs`
    gwlb = "security_gwlb"

    interfaces = {
      private = {
        device_index   = 0
        security_group = "vmseries_private"
        subnet = {
          "privatea" = "us-east-1a",
          "privateb" = "us-east-1b"
        }
        create_public_ip  = false
        source_dest_check = false
      }
      mgmt = {
        device_index   = 1
        security_group = "vmseries_mgmt"
        subnet = {
          "mgmta" = "us-east-1a",
          "mgmtb" = "us-east-1b"
        }
        create_public_ip  = true
        source_dest_check = true
      }
      public = {
        device_index   = 2
        security_group = "vmseries_public"
        subnet = {
          "publica" = "us-east-1a",
          "publicb" = "us-east-1b"
        }
        create_public_ip  = false
        source_dest_check = false
      }
    }

    # Value of `gwlb_endpoint` must match key of objects stored in `gwlb_endpoints`
    subinterfaces = {
      inbound = {
        app1 = {
          gwlb_endpoint = "app1_inbound"
          subinterface  = "ethernet1/1.11"
        }
      }
      outbound = {
        only_1_outbound = {
          gwlb_endpoint = "security_gwlb_outbound"
          subinterface  = "ethernet1/1.20"
        }
      }
      eastwest = {
        only_1_eastwest = {
          gwlb_endpoint = "security_gwlb_eastwest"
          subinterface  = "ethernet1/1.30"
        }
      }
    }

    asg = {
      desired_cap                     = 2 
      min_size                        = 2 
      max_size                        = 2 
      lambda_execute_pip_install_once = true
    }

    scaling_plan = {
      enabled              = true               # Ajustar antes do deploy
      metric_name          = "panSessionActive" # Ajustar antes do deploy
      target_value         = 85                 # Ajustar antes do deploy
      statistic            = "Average"          # Ajustar antes do deploy
      cloudwatch_namespace = "vmseries" # Ajustar antes do deploy
      tags = {
        managedby = "terraform" # Ajustar antes do deploy
      }
    }

    delicense = {
      enabled        = true
      ssm_param_name = "ssm" # Ajustar antes do deploy
    }
  }
}

### PANORAMA
panorama_attachment = {
  transit_gateway_attachment_id = null            # Ajustar antes do deploy
  vpc_cidr                      = null 		  # Ajustar antes do deploy
}

### SPOKE VMS
spoke_vms = {
  "app1_vm01" = {
    az             = "us-east-1a"
    vpc            = "app1_vpc"
    vpc_subnet     = "app1_vpc-app1_vm"
    security_group = "app1_vm"
    type           = "t2.micro"
  }
  "app1_vm02" = {
    az             = "us-east-1b"
    vpc            = "app1_vpc"
    vpc_subnet     = "app1_vpc-app1_vm"
    security_group = "app1_vm"
    type           = "t2.micro"
  }
}

### SPOKE LOADBALANCERS
spoke_lbs = {
  "app1-nlb" = {
    vpc_subnet = "app1_vpc-app1_lb"
    vms        = ["app1_vm01", "app1_vm02"]
  }
}
