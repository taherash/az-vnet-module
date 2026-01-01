# How to Pass Subscription ID to Terraform

This module requires an Azure Subscription ID to deploy resources. Choose **ONE** of the three methods below.

---

## **Method 1: Azure CLI (Recommended for Local Development)**

**Simplest approach if you use Azure CLI locally.**

```bash
# Step 1: Login to Azure
az login

# Step 2: Set your subscription (replace with your actual subscription ID)
az account set --subscription "caa507fd-1b6b-4578-81dd-947418407c4a"

# Step 3: Verify the correct subscription is active
az account show --query "{Name:name, ID:id, TenantID:tenantId}"

# Step 4: Run Terraform
terraform init
terraform plan
terraform apply
```

**Pros:**
- ✅ Simple, no secrets in code
- ✅ Uses existing CLI session
- ✅ No need to set variables

**Cons:**
- ❌ Only works if you're logged in locally
- ❌ Doesn't work in automated CI/CD (requires interactive login)

---

## **Method 2: Environment Variables (Recommended for CI/CD)**

**Best for GitHub Actions, GitLab CI, Azure DevOps, or other automation.**

```bash
# Set all required environment variables
export ARM_SUBSCRIPTION_ID="caa507fd-1b6b-4578-81dd-947418407c4a"
export ARM_TENANT_ID="aff034d7-e6f2-47b1-a60f-4f3f7c608696"
export ARM_CLIENT_ID="<your-client-id>"
export ARM_CLIENT_SECRET="<your-client-secret>"

# Verify subscription is set
echo $ARM_SUBSCRIPTION_ID

# Run Terraform
terraform init
terraform plan
terraform apply
```

**For CI/CD pipelines (example: GitHub Actions):**

```yaml
name: Terraform Plan
on: [push]

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Plan
        env:
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
        run: |
          terraform init
          terraform plan -var-file=examples/prod.tfvars
```

**Pros:**
- ✅ Works in automated CI/CD
- ✅ No secrets in code
- ✅ Flexible for multiple environments

**Cons:**
- ❌ Need to manage multiple secrets
- ❌ More setup required

---

## **Method 3: Terraform Variable (Most Flexible - NOW ENABLED)**

**Pass subscription ID as a Terraform variable. Easy to override per environment.**

### **Option A: Command Line (Quick Testing)**

```bash
terraform plan \
  -var="subscription_id=caa507fd-1b6b-4578-81dd-947418407c4a"

# Or with var-file
terraform plan \
  -var-file=examples/dev.tfvars \
  -var="subscription_id=caa507fd-1b6b-4578-81dd-947418407c4a"
```

### **Option B: terraform.tfvars (Persistent, Local Only)**

**Create or edit `terraform.tfvars`:**

```hcl
subscription_id = "caa507fd-1b6b-4578-81dd-947418407c4a"
```

**Then run:**

```bash
terraform init
terraform plan
```

⚠️ **CAUTION:** This file is in `.gitignore`. Do NOT commit secrets to version control.

### **Option C: Environment Variable TF_VAR_*  (Hybrid Approach)**

```bash
# Set as environment variable
export TF_VAR_subscription_id="caa507fd-1b6b-4578-81dd-947418407c4a"

# Run Terraform
terraform init
terraform plan
```

### **Option D: Per-Environment var-files (Recommended Production Pattern)**

Use the provided example files with subscription ID pre-set:

**For development:**

```bash
# Edit examples/dev.tfvars and uncomment subscription_id, then:
terraform plan -var-file=examples/dev.tfvars
```

**For production:**

```bash
# Edit examples/prod.tfvars and uncomment subscription_id, then:
terraform plan -var-file=examples/prod.tfvars
```

Or pass via command line without editing files:

```bash
terraform plan \
  -var-file=examples/prod.tfvars \
  -var="subscription_id=<prod-subscription-id>"
```

**Pros:**
- ✅ Explicit and easy to override per environment
- ✅ Works with var-files for per-environment configuration
- ✅ Flexible: CLI, tfvars, or env vars

**Cons:**
- ❌ Must not commit secrets to tfvars
- ❌ Slightly more setup than Method 1

---

## **Quick Comparison Table**

| Method | Local Dev | CI/CD | Security | Ease of Use |
|--------|-----------|-------|----------|------------|
| **Method 1 (CLI)** | ⭐⭐⭐ Excellent | ❌ No | ✅ Excellent | ⭐⭐⭐ |
| **Method 2 (Env Vars)** | ⭐⭐ OK | ⭐⭐⭐ Excellent | ✅ Good | ⭐⭐ |
| **Method 3 (Terraform)** | ⭐⭐⭐ Excellent | ⭐⭐ OK | ⚠️ Be careful | ⭐⭐⭐ |

---

## **Recommended Setup by Use Case**

### **Local Development (You)**
```bash
az login
az account set --subscription "<your-subscription-id>"
terraform init
terraform plan
```

### **Team CI/CD (GitHub Actions/Azure DevOps)**
Use **Method 2** with secrets stored in your CI provider:
```bash
export ARM_SUBSCRIPTION_ID="${{ secrets.AZURE_SUBSCRIPTION_ID }}"
terraform plan -var-file=examples/prod.tfvars
```

### **Easy Per-Environment Switching**
Use **Method 3** with var-files:
```bash
terraform plan -var-file=examples/dev.tfvars -var="subscription_id=<dev-id>"
terraform plan -var-file=examples/prod.tfvars -var="subscription_id=<prod-id>"
```

---

## **Finding Your Subscription ID**

```bash
# List all subscriptions
az account list --output table

# Show current subscription
az account show --query id -o tsv
```

---

## **Troubleshooting**

**Error: "The client <ID> does not have authorization to perform action..."**
- Ensure the subscription ID is correct
- Verify the account/service principal has appropriate Azure RBAC roles

**Error: "Subscription not found"**
- Check subscription ID format (should be a UUID like `caa507fd-1b6b-4578-81dd-947418407c4a`)
- Verify subscription is active: `az account list --output table`

**Error: "resource_group_name not found"**
- Subscription is set correctly, but the resource group doesn't exist
- Create it: `az group create --name Taher --location eastus`
- Or change `resource_group_name` in variables/tfvars

---

## **Next Steps**

1. Choose your preferred method above
2. Run: `terraform init`
3. Run: `terraform plan` (with appropriate subscription_id set)
4. Review the plan output
5. Run: `terraform apply` to deploy
