# Makefile for Terraform Complex Structure
# Manages operations in controller_workspaces directory

ENV ?= sandbox
CONTROLLER_DIR := stack/$(ENV)/controller_workspaces
TF := terraform

.PHONY: help init plan apply destroy clean fmt validate

help: ## Show this help message
	@echo 'Usage: make [target] ENV=[sandbox|prod]'
	@echo ''
	@echo 'Environment: $(ENV) (default: sandbox)'
	@echo 'Controller: $(CONTROLLER_DIR)'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ''
	@echo 'Examples:'
	@echo '  make init              # Initialize sandbox (default)'
	@echo '  make plan ENV=prod     # Plan for prod environment'
	@echo '  make apply ENV=sandbox # Apply sandbox environment'

init: ## Initialize Terraform in controller_workspaces
	@echo "Initializing Terraform in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) init

init-upgrade: ## Initialize with upgrade in controller_workspaces
	@echo "Initializing Terraform with upgrade in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) init -upgrade

plan: ## Run terraform plan in controller_workspaces
	@echo "Running Terraform plan in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) plan

apply: ## Run terraform apply in controller_workspaces
	@echo "Applying Terraform configuration in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) apply

apply-auto-approve: ## Run terraform apply with auto-approve in controller_workspaces
	@echo "Applying Terraform configuration with auto-approve in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) apply -auto-approve

destroy: ## Destroy Terraform resources in controller_workspaces
	@echo "Destroying Terraform resources in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) destroy

destroy-auto-approve: ## Destroy Terraform resources with auto-approve in controller_workspaces
	@echo "Destroying Terraform resources with auto-approve in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) destroy -auto-approve

fmt: ## Format all Terraform files
	@echo "Formatting Terraform files..."
	$(TF) fmt -recursive .

validate: ## Validate Terraform configuration in controller_workspaces
	@echo "Validating Terraform configuration in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) validate

clean: ## Clean Terraform state files and directories in controller_workspaces
	@echo "Cleaning Terraform state files in $(CONTROLLER_DIR)..."
	rm -rf $(CONTROLLER_DIR)/.terraform
	rm -f $(CONTROLLER_DIR)/.terraform.lock.hcl
	rm -f $(CONTROLLER_DIR)/terraform.tfstate
	rm -f $(CONTROLLER_DIR)/terraform.tfstate.backup

clean-all: ## Clean all Terraform state files across all workspaces
	@echo "Cleaning all Terraform state files..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "terraform.tfstate*" -delete

show: ## Show current Terraform state in controller_workspaces
	@echo "Showing Terraform state in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) show

output: ## Show Terraform outputs in controller_workspaces
	@echo "Showing Terraform outputs in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) output

refresh: ## Refresh Terraform state in controller_workspaces
	@echo "Refreshing Terraform state in $(CONTROLLER_DIR)..."
	cd $(CONTROLLER_DIR) && $(TF) refresh
