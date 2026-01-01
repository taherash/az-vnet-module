locals {
  region       = "eastus"
  environment  = "development"
  tenant_id    = "aff034d7-e6f2-47b1-a60f-4f3f7c608696" # CAUTION: Do not commit real subscription/tenant IDs to version control
  project_name = "az-vnet"
}

# NOTE: Subscription ID is NOT needed here. Configure it at the provider level:
# - Option 1: Set environment variable: export ARM_SUBSCRIPTION_ID="<subscription-id>"
# - Option 2: Use Azure CLI: az account set --subscription <subscription-id>
# - Option 3: Add to provider.tf: subscription_id = var.subscription_id
