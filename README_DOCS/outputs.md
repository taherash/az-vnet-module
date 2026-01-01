# Module Outputs Reference

This document describes all outputs exposed by the `az-vnet-module`. Use these outputs in downstream repos to reference the created VNet and subnets.

## Quick Reference Table

| Output Name | Type | Description | Example Usage |
|-----------|------|-------------|----------------|
| `vnet` | object | Full virtual network resource object | `data.terraform_remote_state.vnet.outputs.vnet.id` |
| `subnets` | map(object) | Map of all subnets indexed by name | `data.terraform_remote_state.vnet.outputs.subnets["t-public"].id` |
| `subnet_nsg_ids` | map(string) | Map of subnet IDs to NSG IDs | `data.terraform_remote_state.vnet.outputs.subnet_nsg_ids[subnet_id]` |
| `subnet_nsg_names` | map(string) | Map of subnet names to NSG names | `data.terraform_remote_state.vnet.outputs.subnet_nsg_names["t-public"]` |
| `route_tables` | map(object) | Map of custom route tables | `data.terraform_remote_state.vnet.outputs.route_tables["default"].id` |
| `aks` | map(object) | AKS-specific subnet/route info | `data.terraform_remote_state.vnet.outputs.aks[aks_id].subnet.id` |

---

## Detailed Output Descriptions

### `vnet`

**Type:** `object` (azurerm_virtual_network)

**Description:** The complete virtual network resource object created by the module.

**Shape:**
```hcl
{
  id              = string    # e.g., "/subscriptions/.../virtualNetworks/tg-prod-eastus-vnet"
  name            = string    # e.g., "tg-prod-eastus-vnet"
  address_space   = list(string) # e.g., ["10.0.0.0/22"]
  location        = string    # e.g., "eastus"
  resource_group_name = string # e.g., "Taher"
  # ... other azurerm_virtual_network attributes
}
```

**Usage in VM repo:**
```hcl
data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = { ... }
}

# Reference the VNet ID
vnet_id = data.terraform_remote_state.vnet.outputs.vnet.id

# Or use in outputs for downstream consumers
output "vnet_id" {
  value = data.terraform_remote_state.vnet.outputs.vnet.id
}
```

---

### `subnets`

**Type:** `map(object)`

**Description:** Map of all subnets created by the module. Keys are subnet type names (e.g., "t-public", "t-private", "t-outbound"). Each value is a subnet object with all relevant properties.

**Shape (per subnet entry):**
```hcl
{
  name                        = string    # e.g., "t-public"
  id                          = string    # e.g., "/subscriptions/.../subnets/t-public"
  resource_group_name         = string    # e.g., "Taher"
  address_prefixes            = list(string) # e.g., ["10.0.1.0/26"]
  service_endpoints           = list(string) # e.g., []
  network_security_group_name = string    # e.g., "rg-taher-t-public-security-group"
  network_security_group_id   = string    # e.g., "/subscriptions/.../networkSecurityGroups/..."
  virtual_network_name        = string    # e.g., "tg-prod-eastus-vnet"
  virtual_network_id          = string    # e.g., "/subscriptions/.../virtualNetworks/..."
  route_table_id              = string or null # e.g., "/subscriptions/.../routeTables/..." or null
}
```

**Available subnet keys (based on your config):**
- `"t-public"` — public subnet
- `"t-private"` — private subnet
- `"t-outbound"` — outbound subnet

**Usage in VM repo:**

Create a NIC in the public subnet:
```hcl
data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = { ... }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "my-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.subnets["t-public"].id
    private_ip_address_allocation = "Dynamic"
  }
}
```

Iterate over all subnets:
```hcl
locals {
  subnets = data.terraform_remote_state.vnet.outputs.subnets
}

resource "azurerm_log_analytics_workspace" "workspace_per_subnet" {
  for_each = local.subnets

  name                = "${each.key}-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  # ... other config
}
```

---

### `subnet_nsg_ids`

**Type:** `map(string)`

**Description:** Map of subnet IDs to their associated network security group IDs. Useful for directly assigning NSGs to subnets created by your VM module.

**Shape:**
```hcl
{
  "/subscriptions/.../subnets/t-public"   = "/subscriptions/.../networkSecurityGroups/rg-taher-t-public-security-group"
  "/subscriptions/.../subnets/t-private"  = "/subscriptions/.../networkSecurityGroups/rg-taher-t-private-security-group"
  "/subscriptions/.../subnets/t-outbound" = "/subscriptions/.../networkSecurityGroups/rg-taher-t-outbound-security-group"
}
```

**Usage:**
```hcl
data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = { ... }
}

resource "azurerm_network_interface_security_group_association" "my_vm_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.subnet_nsg_ids[azurerm_network_interface.vm_nic.subnet_id]
}
```

---

### `subnet_nsg_names`

**Type:** `map(string)`

**Description:** Map of subnet names to their associated NSG names. Useful if you need to reference NSG names instead of IDs.

**Shape:**
```hcl
{
  "t-public"   = "rg-taher-t-public-security-group"
  "t-private"  = "rg-taher-t-private-security-group"
  "t-outbound" = "rg-taher-t-outbound-security-group"
}
```

**Usage:**
```hcl
nsg_name = data.terraform_remote_state.vnet.outputs.subnet_nsg_names["t-public"]
```

---

### `route_tables`

**Type:** `map(object)`

**Description:** Map of custom route tables defined in the module. Keys match the route table names from your module configuration (e.g., "default").

**Shape (per route table entry):**
```hcl
{
  name    = string     # e.g., "Taher-default-routetable"
  id      = string     # e.g., "/subscriptions/.../routeTables/..."
  subnets = list(object) # Associated subnets
}
```

**Usage:**
```hcl
route_table_id = data.terraform_remote_state.vnet.outputs.route_tables["default"].id
```

---

### `aks`

**Type:** `map(object)`

**Description:** AKS-specific output format. Only populated if you define AKS subnets in the module configuration. Provides subnet and route table info in the format expected by AKS modules.

**Shape (per AKS entry):**
```hcl
{
  subnet = {
    name                        = string
    id                          = string
    resource_group_name         = string
    address_prefixes            = list(string)
    service_endpoints           = list(string)
    network_security_group_id   = string
    network_security_group_name = string
    virtual_network_name        = string
    virtual_network_id          = string
    route_table_id              = string
  }
  route_table = {
    id   = string
    name = string
  }
}
```

**Usage (if you have AKS subnets):**
```hcl
aks_subnet_info = data.terraform_remote_state.vnet.outputs.aks["my-aks-cluster"]

module "aks_cluster" {
  subnet_id = aks_subnet_info.subnet.id
  # ... other AKS config
}
```

---

## Integration Patterns: Three Approaches

Choose the approach that best fits your architecture and team structure.

---

### **Pattern A: Terraform Remote State (Recommended for tightly-coupled teams)**

**How it works**: Reads module outputs directly from the Terraform state file in Azure Blob Storage.

**Setup in VM repo:**

**In your VM repo's `variables.tf`:**
```hcl
variable "vnet_remote_state_config" {
  description = "Remote state config for the VNet module"
  type = object({
    storage_account_name = string
    container_name       = string
    key                  = string
    resource_group_name  = string
  })
}
```

**In your VM repo's `main.tf`:**
```hcl
data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config  = var.vnet_remote_state_config
}

locals {
  vnet_outputs = data.terraform_remote_state.vnet.outputs
}

# Now use the outputs
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = local.vnet_outputs.subnets["t-public"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = local.vnet_outputs.subnets["t-private"].network_security_group_id
}
```

**In your VM repo's `terraform.tfvars` (or `examples/dev.tfvars`):**
```hcl
vnet_remote_state_config = {
  storage_account_name = "mystorageaccount"
  container_name       = "vnet-state"
  key                  = "terraform.tfstate"
  resource_group_name  = "Taher"
}
```

**Pros:**
- ✅ Fast (reads state file, no Azure API calls)
- ✅ Uses curated module outputs (single source of truth)
- ✅ Simple reference syntax: `data.terraform_remote_state.vnet.outputs.subnets["t-public"].id`
- ✅ VM repo inherits all upstream improvements automatically

**Cons:**
- ❌ Depends on remote state file availability
- ❌ If state is lost/deleted, outputs become inaccessible
- ❌ Tight coupling to upstream module's output structure
- ❌ Requires both repos to use same backend storage

---

### **Pattern B: Azure Data Sources (Recommended for loosely-coupled teams)**

**How it works**: Queries Azure directly using data sources to look up existing VNet and subnets by name.

**Setup in VM repo:**

**In your VM repo's `variables.tf`:**
```hcl
variable "vnet_name" {
  description = "Name of the existing VNet"
  type        = string
  default     = "tg-prod-eastus-vnet"
}

variable "vnet_resource_group" {
  description = "Resource group of the existing VNet"
  type        = string
  default     = "Taher"
}

variable "subnet_names" {
  description = "Names of subnets to lookup"
  type = object({
    public  = string
    private = string
    outbound = string
  })
  default = {
    public   = "t-public"
    private  = "t-private"
    outbound = "t-outbound"
  }
}
```

**In your VM repo's `main.tf`:**
```hcl
# Lookup the existing VNet
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

# Lookup public subnet
data "azurerm_subnet" "public" {
  name                 = var.subnet_names.public
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.vnet_resource_group
}

# Lookup private subnet
data "azurerm_subnet" "private" {
  name                 = var.subnet_names.private
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.vnet_resource_group
}

# Lookup outbound subnet
data "azurerm_subnet" "outbound" {
  name                 = var.subnet_names.outbound
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.vnet_resource_group
}

# Or use a dynamic approach with a map
locals {
  subnets = {
    public   = data.azurerm_subnet.public
    private  = data.azurerm_subnet.private
    outbound = data.azurerm_subnet.outbound
  }
}

# Create VM NIC using the data source
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Lookup NSG by name and associate it
data "azurerm_network_security_group" "private_nsg" {
  name                = "t-private-nsg"  # or derive from subnet naming pattern
  resource_group_name = var.vnet_resource_group
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = data.azurerm_network_security_group.private_nsg.id
}
```

**In your VM repo's `terraform.tfvars` (or `examples/dev.tfvars`):**
```hcl
vnet_name            = "tg-prod-eastus-vnet"
vnet_resource_group  = "Taher"

subnet_names = {
  public   = "t-public"
  private  = "t-private"
  outbound = "t-outbound"
}
```

**Pros:**
- ✅ No dependency on Terraform state files
- ✅ Queries Azure directly (always current)
- ✅ Works even if upstream state is lost/deleted
- ✅ Loose coupling between VNet and VM repos
- ✅ Different teams can manage repos independently
- ✅ Can migrate/recreate VNet without breaking VM repo logic

**Cons:**
- ❌ Slower (Azure API calls for each data source)
- ❌ Must know exact resource names beforehand
- ❌ If resource names change, lookups break
- ❌ No automatic updates if upstream module structure changes
- ❌ More verbose (one data source per resource type)

---

### **Pattern C: Hybrid Approach (Maximum flexibility)**

**How it works**: Try remote state first; fall back to data sources if state unavailable.

**Setup in VM repo:**

**In your VM repo's `main.tf`:**
```hcl
# Optionally read remote state
data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = try(
    var.vnet_remote_state_config,
    {
      storage_account_name = "dummy"
      container_name       = "dummy"
      key                  = "dummy"
      resource_group_name  = "dummy"
    }
  )
}

# Also define data sources as fallback
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

data "azurerm_subnet" "public" {
  name                 = var.subnet_names.public
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.vnet_resource_group
}

# Use local to select which to use (prefer remote state if available)
locals {
  # Prefer remote state if available; fall back to data sources
  vnet_id = try(
    data.terraform_remote_state.vnet.outputs.vnet.id,
    data.azurerm_virtual_network.vnet.id
  )
  
  # For subnets, prefer remote state
  subnets = try(
    data.terraform_remote_state.vnet.outputs.subnets,
    {
      "t-public"   = data.azurerm_subnet.public
      "t-private"  = data.azurerm_subnet.private
      "t-outbound" = data.azurerm_subnet.outbound
    }
  )
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = local.subnets["t-public"].id
    private_ip_address_allocation = "Dynamic"
  }
}
```

**Pros:**
- ✅ Best of both worlds
- ✅ Uses remote state when available (fast)
- ✅ Falls back to data sources if state unavailable (resilient)
- ✅ Maximum flexibility for team transitions
- ✅ Can switch between patterns without code changes

**Cons:**
- ❌ More complex (both patterns must be maintained)
- ⚠️ Debugging can be trickier (which source was used?)
- ⚠️ Slight performance overhead (both lookups attempted)

---

## Comparison Table

| Feature | Pattern A (Remote State) | Pattern B (Data Sources) | Pattern C (Hybrid) |
|---------|--------------------------|--------------------------|-------------------|
| **Speed** | 🚀 Fast | 🐌 Slower (API calls) | 🚀 Fast (preferred) |
| **State Dependency** | ❌ Required | ✅ None | ⚠️ Optional |
| **Coupling** | 🔗 Tight | 🔓 Loose | 🔗/🔓 Flexible |
| **Resilience** | ⚠️ Fragile | ✅ Robust | ✅ Very Robust |
| **Complexity** | ✅ Simple | ⚠️ Moderate | ❌ Complex |
| **Team Independence** | ❌ No | ✅ Yes | ✅ Yes |
| **Automatic Updates** | ✅ Yes | ❌ No | ✅ Yes (if state) |

---

## Recommendation by Scenario

| Scenario | Best Pattern |
|----------|--------------|
| **Single team, same org, coordinated deploys** | **Pattern A** (Remote State) |
| **Different teams, need independence** | **Pattern B** (Data Sources) |
| **Enterprise, need flexibility to migrate** | **Pattern C** (Hybrid) |
| **High availability, state criticality** | **Pattern B** (Data Sources) |
| **Rapid prototyping, single repo** | **Pattern A** (Remote State) |
| **Multi-cloud, multi-subscription** | **Pattern B** (Data Sources) |

---

## Troubleshooting

**Error: "state not found"**
- Ensure the VNet module has been deployed and its state is in the remote backend (Blob Storage).
- Verify the storage account name, container, key, and resource group are correct in your `vnet_remote_state_config`.

**Error: "key 'subnet_name' does not exist"**
- Check the actual subnet names in your VNet module config. The default subnet keys are `"t-public"`, `"t-private"`, `"t-outbound"`.
- Use `terraform console` in the VM repo to inspect: `data.terraform_remote_state.vnet.outputs.subnets`

**Subnets appear empty**
- Ensure the VNet module ran `terraform apply` successfully.
- Verify that `terraform_remote_state` is pointing to the correct backend location.
