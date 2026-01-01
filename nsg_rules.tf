# Network Security Group Rules
# Allows SSH (22), DNS (53), and HTTPS (443) traffic inbound and outbound
# Applied to all subnets: t-public-sn-dev-sn-dev, t-private-sn-dev, t-outbound

# ===========================
# Public Subnet NSG Rules
# ===========================

resource "azurerm_network_security_rule" "public_inbound_ssh" {
  name                        = "AllowSSHInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-public-sn-dev"].network_security_group_name
}

/*resource "azurerm_network_security_rule" "public_inbound_dns" {
  name                        = "AllowDNSInbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-public-sn-dev"].network_security_group_name
}*/

resource "azurerm_network_security_rule" "public_inbound_https" {
  name                        = "AllowHTTPSInbound"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-public-sn-dev"].network_security_group_name
}

resource "azurerm_network_security_rule" "public_outbound_ssh" {
  name                        = "AllowSSHOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-public-sn-dev"].network_security_group_name
}

/*resource "azurerm_network_security_rule" "public_outbound_dns" {
  name                        = "AllowDNSOutbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-public-sn-dev"].network_security_group_name
}*/

resource "azurerm_network_security_rule" "public_outbound_https" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-public-sn-dev"].network_security_group_name
}

# ===========================
# Private Subnet NSG Rules
# ===========================

resource "azurerm_network_security_rule" "private_inbound_ssh" {
  name                        = "AllowSSHInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-private-sn-dev"].network_security_group_name
}

/*resource "azurerm_network_security_rule" "private_inbound_dns" {
  name                        = "AllowDNSInbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-private-sn-dev"].network_security_group_name
}*/

resource "azurerm_network_security_rule" "private_inbound_https" {
  name                        = "AllowHTTPSInbound"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-private-sn-dev"].network_security_group_name
}

resource "azurerm_network_security_rule" "private_outbound_ssh" {
  name                        = "AllowSSHOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-private-sn-dev"].network_security_group_name
}

/*resource "azurerm_network_security_rule" "private_outbound_dns" {
  name                        = "AllowDNSOutbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-private-sn-dev"].network_security_group_name
}*/

resource "azurerm_network_security_rule" "private_outbound_https" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-private-sn-dev"].network_security_group_name
}

# ===========================
# Outbound Subnet NSG Rules
# ===========================

/*resource "azurerm_network_security_rule" "outbound_inbound_ssh" {
  name                        = "AllowSSHInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-outbound"].network_security_group_name
}

resource "azurerm_network_security_rule" "outbound_inbound_dns" {
  name                        = "AllowDNSInbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-outbound"].network_security_group_name
}

resource "azurerm_network_security_rule" "outbound_inbound_https" {
  name                        = "AllowHTTPSInbound"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-outbound"].network_security_group_name
}

resource "azurerm_network_security_rule" "outbound_outbound_ssh" {
  name                        = "AllowSSHOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-outbound"].network_security_group_name
}

resource "azurerm_network_security_rule" "outbound_outbound_dns" {
  name                        = "AllowDNSOutbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-outbound"].network_security_group_name
}

resource "azurerm_network_security_rule" "outbound_outbound_https" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.azure_virt_network.subnets["t-outbound"].network_security_group_name
}
*/