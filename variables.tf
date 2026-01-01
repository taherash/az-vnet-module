variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  #default     = "Taher"
}

variable "location" {
  description = "Azure Location"
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
  # Leave empty and set via: terraform plan -var="subscription_id=<id>"
  # Or set in terraform.tfvars: subscription_id = "..."
  # Or set environment variable: export TF_VAR_subscription_id="..."
  default = ""
}

variable "names" {
  type = map(string)
  default = {
    product_group       = "tg"
    product_name        = "taher"
    subscription_type   = "prod"
    resource_group_type = "rg"
    location            = "eastus"
    vnet                = "my-vnet"
    subnet              = "my-subnet"
  }
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
  default     = "tahervnet"
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  # Smaller VNet block (/22) to limit address range for this environment
  default = ["10.0.0.0/22"]
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  # smaller subnet (/26) — 64 addresses
  default = "10.0.1.0/26"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  type        = string
  default     = "10.0.1.64/26"
}

variable "outbound_subnet_cidr" {
  description = "CIDR for the outbound subnet"
  type        = string
  default     = "10.0.1.128/26"
}

variable "internal_route_cidr" {
  description = "CIDR for the internal route"
  type        = string
  # route prefix used for example internal routing — keep distinct from subnet prefixes
  default = "10.0.3.0/24"
}

variable "internal_next_hop_ip" {
  description = "Next hop IP address for the internal route"
  type        = string
  default     = "10.0.2.4"
}