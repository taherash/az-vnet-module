**Azure VNet Module — az-vnet-module**

- **Purpose**: Reusable Terraform configuration that provisions an Azure Virtual Network and related subnets, NSGs, and route tables using the upstream `terraform-azurerm-virtual-network` module.

**Quick Start**
- Clone repository and authenticate to Azure (recommended local workflow):

```bash
az login
az account set --subscription <your-subscription-id>
terraform init
terraform plan
```

**Authentication Options**
- **Azure CLI (recommended for local development)**: `az login` and set subscription as above. The provider uses CLI or env vars.
- **Environment variables**: set `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID` (avoid committing secrets).
- **Service principal**: use `az ad sp create-for-rbac` to create credentials if needed for CI.

**Files of interest**
- **`variables.tf`**: module / root variable declarations and defaults (canonical defaults).
- **`terraform.tfvars`**: environment overrides; keep minimal (only values you want to override).
- **`main.tf`**: module invocation and high-level configuration.
- **`provider.tf`**: provider configuration (uses CLI/env authentication).

**Important Variables (summary)**
- **`resource_group_name`**: Resource group where VNet and subnets are created (default: `Taher`).
- **`location`**: Azure region (default in `variables.tf` is `eastus`).
- **`names`** (map(string)): naming components used by the upstream module. Keys expected:
  - `product_group`, `product_name`, `subscription_type`, `resource_group_type`, `location`, `vnet`, `subnet`
  - Provide this map in `terraform.tfvars` or rely on the defaults in `variables.tf`.
- **Subnet CIDRs**: `public_subnet_cidr`, `private_subnet_cidr`, `outbound_subnet_cidr` (defaults in `variables.tf`).

**Subnets structure**
- The module expects `subnets` to be a map where each value can include fields like:
  - `cidrs` (list of CIDRs)
  - `allow_vnet_inbound`, `allow_vnet_outbound`, `allow_internet_outbound`, `allow_lb_inbound` (booleans)
  - `default_outbound_access_enabled` (bool)
  - `private_endpoint_network_policies` (string)
  - `private_link_service_network_policies_enabled` (bool)
  - `delegations` (map of delegation objects)

Example (in `main.tf` the repo sets this already):
```hcl
subnets = {
  "t-public" = { cidrs = [var.public_subnet_cidr], default_outbound_access_enabled = false }
  "t-private" = { cidrs = [var.private_subnet_cidr], default_outbound_access_enabled = false }
  "t-outbound" = { cidrs = [var.outbound_subnet_cidr], default_outbound_access_enabled = false }
}
```

**Usage (module call)**
- The root `main.tf` invokes the external module at `github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v8.2.0` and supplies `names = var.names` and other variables. Keep `names` centralized in `variables.tf` (defaults) or in `terraform.tfvars` (overrides).

**Best practices**
- Avoid committing secrets: add `terraform.tfvars` to `.gitignore` if it will contain sensitive values.
- Prefer `az login` for local work; use a service principal or managed identity for CI.
- Keep `terraform.tfvars` minimal — only environment-specific overrides.
- Normalize `location` values (e.g., `eastus`) to avoid inconsistent names.

**Applying changes**
```bash
terraform init
terraform plan
terraform apply
```

**Per-environment variable files**

Keep per-environment variable files that only contain overrides. Example files are provided in the repo under the `examples/` directory:

- `examples/dev.tfvars` — development environment overrides
- `examples/prod.tfvars` — production environment overrides

Example `dev.tfvars` usage:
```bash
terraform init
terraform plan -var-file=examples/dev.tfvars
terraform apply -var-file=examples/dev.tfvars
```

Notes:
- Put environment-specific secrets in your CI secret store or use environment variables; do not commit secrets.
- `terraform.tfvars` remains useful as a default environment file; prefer `-var-file` for per-environment runs to avoid accidental application to the wrong environment.

**Injecting secrets in CI**

Use your CI provider's secret storage and inject secrets as environment variables at runtime. Examples below show common patterns.

- GitHub Actions (recommended: store an `AZURE_CREDENTIALS` JSON created with `az ad sp create-for-rbac --sdk-auth` or store individual ARM_* secrets):

```yaml
name: terraform
on: [push]
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Init & Plan
        env:
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_CLIENT_ID:       ${{ secrets.AZURE_CLIENT_ID }}
          ARM_CLIENT_SECRET:   ${{ secrets.AZURE_CLIENT_SECRET }}
          ARM_TENANT_ID:       ${{ secrets.AZURE_TENANT_ID }}
        run: |
          terraform init
          terraform plan -var-file=examples/dev.tfvars
```

- Azure DevOps pipeline (use pipeline variable groups or Azure Key Vault integration):

```yaml
trigger: none
pool:
  vmImage: 'ubuntu-latest'
steps:
- checkout: self
- task: AzureCLI@2
  inputs:
    azureSubscription: 'MyServiceConnection'
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
      terraform init
      terraform plan -var-file=examples/prod.tfvars
```

Tips:
- Use `AZURE_CREDENTIALS` (SDK auth JSON) for `azure/login` action to avoid exposing individual client secrets.
- Avoid writing secrets to disk; pass them via environment variables or use your CI provider's secret injection.
- Consider using a secret store (Azure Key Vault) with short-lived credentials or managed identity in hosted runners.

**Consuming Module Outputs (for downstream VM/AKS repos)**

This module exposes outputs for downstream resources (VMs, NICs, load balancers, AKS clusters). See [outputs.md](outputs.md) for:
- Complete list of all available outputs
- Detailed descriptions and shapes of each output
- Three integration patterns (remote state, data sources, hybrid) with full code examples
- Trade-offs and recommendations by scenario
- Troubleshooting guide

**Quick Reference: Three Integration Patterns**

**Pattern 1: Same root module** — if VNet and VMs are in the same Terraform root, reference module outputs directly: `module.azure_virt_network.subnets["t-public"].id`

**Pattern A (Remote State)** — separate repos, same team: use `data.terraform_remote_state.vnet.outputs.subnets["t-public"].id`

**Pattern B (Data Sources)** — separate repos, different teams: use `data.azurerm_subnet.public.id` (lookup by name)

**Pattern C (Hybrid)** — maximum flexibility: try remote state first, fall back to data sources

👉 **See [outputs.md](outputs.md) for complete setup instructions, code examples, and comparison table.**

**Integration checklist**
- [ ] Decide: same-root apply (Pattern 1) or separate repos (Pattern 2 or 3)?
- [ ] Always use subnet IDs (not names) when creating NICs and VMs; IDs are unique and stable.
- [ ] If using the module's NSGs, don't create additional NSGs for the same subnets (avoids conflicts).
- [ ] Ensure downstream code uses the same `resource_group_name` and `location` as the VNet.
- [ ] Test your downstream integration in a dev environment first using `examples/dev.tfvars`.

**Contributing**
- Open issues or PRs to suggest improvements. Keep variable defaults reasonable for development and put environment-specific configuration into `terraform.tfvars` files per environment.

**Contact / Notes**
- This repo references the upstream Azure-Terraform module (v8.2.0). See that module's docs for advanced parameters and naming rules.
