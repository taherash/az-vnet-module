data "azurerm_resource_group" "trg" {
  name = var.resource_group_name
}

module "azure_virt_network" {
  source              = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v8.2.0"
  resource_group_name = data.azurerm_resource_group.trg.name
  location            = var.location
  names               = var.names

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }

  address_space = var.address_space

  subnets = {
    "t-public-sn-dev" = {
      cidrs                           = [var.public_subnet_cidr]
      allow_vnet_inbound              = true
      allow_vnet_outbound             = true
      default_outbound_access_enabled = true
      route_table_association         = "default"
    }
    "t-private-sn-dev" = {
      cidrs                           = [var.private_subnet_cidr]
      allow_vnet_inbound              = true
      allow_vnet_outbound             = true
      default_outbound_access_enabled = false
      route_table_association         = "default"
    }
    /*"t-outbound" = {
      cidrs                           = [var.outbound_subnet_cidr]
      allow_vnet_inbound              = true
      allow_vnet_outbound             = true
      default_outbound_access_enabled = false
    }*/
  }

  route_tables = {
    default = {
      bgp_route_propagation_enabled = false
      use_inline_routes             = false
      routes = {
        internet = {
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
        /*internal-1 = {
          address_prefix         = var.internal_route_cidr
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = var.internal_next_hop_ip
        }*/
      }
    }
  }
}