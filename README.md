# Terraform Complex Structuretest

Multi-layer Terraform repository demonstrating modular structure with controller workspaces across multiple environments.

## Structure

### Modules

Reusable Terraform modules used by all environments:

- `modules/common/` - Environment-aware shared configuration
  - Provides environment-specific naming prefixes (tf_sandbox, tf_prod)
  - Common tags with environment label
- `modules/organisation/` - Organisation resource module
- `modules/project/` - Project resource module
- `modules/registry_provider/` - Provider registry module
- `modules/registry_modules/` - Module registry module

### Environments

#### Sandbox (`stack/sandbox/`)

- `controller_workspaces/` - Controllers managing all sandbox workspaces
- `registry_modules/` - Module registry workspace
- `registry_provider/` - Provider registry workspace
- `organisations/` - Organisation workspaces
  - `org-01/` - Organisation 01 with projects 11, 12
  - `org-02/` - Organisation 02 with projects 21, 22

#### Production (`stack/prod/`)

- Same structure as sandbox
- Uses `environment = "prod"` for common module
- Separate state management from sandbox

## Usage

### Using Makefile (Recommended)

The Makefile provides convenient commands for managing both environments:

```bash
# Show all available commands
make help

# Sandbox environment (default)
make init          # Initialize sandbox controller
make plan          # Plan sandbox changes
make validate      # Validate sandbox configuration
make apply         # Apply sandbox changes

# Production environment
make init ENV=prod      # Initialize prod controller
make plan ENV=prod      # Plan prod changes
make validate ENV=prod  # Validate prod configuration
make apply ENV=prod     # Apply prod changes

# Format all Terraform files
make fmt

# Clean state files
make clean              # Clean current environment
make clean-all          # Clean all environments
```

### Direct Terraform Commands

You can also use Terraform directly in specific workspaces:

```bash
# Controller workspaces (manages all workspaces)
cd stack/sandbox/controller_workspaces
terraform init
terraform plan
terraform apply

# Individual workspace
cd stack/sandbox/organisations/org-01
terraform init
terraform plan
terraform apply
```

## Features

### Environment-Aware Configuration

The common module adapts to the environment:

```hcl
# Sandbox
naming_prefix = "tf_sandbox"
common_tags = {
  environment = "sandbox"
  managed_by  = "terraform"
}

# Production
naming_prefix = "tf_prod"
common_tags = {
  environment = "prod"
  managed_by  = "terraform"
}
```

### Controller Workspaces

Controller workspaces use workspace directories as modules to manage the entire environment from a single location:

```hcl
# Controller imports workspaces as modules
module "org_01_workspace" {
  source = "../organisations/org-01"
}

# Exposes org and all projects
output "org_01_workspace" {
  value = {
    org      = module.org_01_workspace.org_01_info
    proj_11  = module.org_01_workspace.proj_11_info
    proj_12  = module.org_01_workspace.proj_12_info
  }
}
```

### Consistent Naming

All resources use underscores for consistency:

- Organisations: `org_01`, `org_02`
- Projects: `proj_11`, `proj_12`, `proj_21`, `proj_22`
- Workspace names: `sandbox_org_01`, `prod_org_02`

## Testing

All modules use the random provider as placeholder for testing directory structure and module references.

## Documentation

- `docs/structure.md` - Original structure diagram
- `docs/plans/` - Implementation plans
# terraform-complex-structure