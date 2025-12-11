# Running the Landing Zone Terraform

This repo uses an Azure Storage Account for remote state and YAML-driven configuration per environment. Replace placeholder backend values with your actual state storage details.

## 1) Initialize remote state backend
Run once per environment (dev/prod) to point Terraform at the correct backend key.

```bash
# dev backend init
terraform -chdir=terraform/core init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=landingzone-dev.tfstate"

# prod backend init
terraform -chdir=terraform/core init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=landingzone-prod.tfstate"
```

## 2) Plan changes
Use the environment-specific YAML to drive which modules deploy and their settings.

```bash
# dev plan
terraform -chdir=terraform/core plan \
  -var "environment=dev" \
  -var "config_file=../../config/envs/dev.landingzone.yaml"

# prod plan
terraform -chdir=terraform/core plan \
  -var "environment=prod" \
  -var "config_file=../../config/envs/prod.landingzone.yaml"
```

## 3) Apply changes
Apply when ready. Ensure you have the correct state key initialized for the target environment.

```bash
# dev apply
terraform -chdir=terraform/core apply -auto-approve \
  -var "environment=dev" \
  -var "config_file=../../config/envs/dev.landingzone.yaml"

# prod apply
terraform -chdir=terraform/core apply -auto-approve \
  -var "environment=prod" \
  -var "config_file=../../config/envs/prod.landingzone.yaml"
```

## Configuration-driven toggles
Each YAML file defines `enabled` flags for modules (e.g., management groups, hub_network, shared_services, logging_monitoring). Terraform reads the YAML via `config_file`; when a module's `enabled` is `false`, it is skipped (count 0), so you can turn features on/off per environment without changing code.
