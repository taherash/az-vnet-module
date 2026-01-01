// Provider configuration for Azure
// Choose ONE of the authentication methods below:

provider "azurerm" {
  features {}

  # METHOD 3: Uncomment below to pass subscription_id as a Terraform variable
  # Set via: terraform plan -var="subscription_id=<id>"
  # Or in terraform.tfvars or environment variable TF_VAR_subscription_id
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
}

# ==========================================
# THREE METHODS TO PASS SUBSCRIPTION_ID:
# ==========================================

# METHOD 1: Azure CLI (simplest for local development)
# $ az login
# $ az account set --subscription <your-subscription-id>
# $ terraform plan

# METHOD 2: Environment variables (best for CI/CD)
# $ export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
# $ export ARM_TENANT_ID="<your-tenant-id>"
# $ export ARM_CLIENT_ID="<your-client-id>"
# $ export ARM_CLIENT_SECRET="<your-client-secret>"
# $ terraform plan

# METHOD 3: Terraform variable (explicit, easy to override per environment)
# Option A: Command line
# $ terraform plan -var="subscription_id=<your-subscription-id>"
#
# Option B: terraform.tfvars
# subscription_id = "<your-subscription-id>"
#
# Option C: Environment variable
# $ export TF_VAR_subscription_id="<your-subscription-id>"
# $ terraform plan
