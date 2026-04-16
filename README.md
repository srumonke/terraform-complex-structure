# Terraform Complex Structure

Multi-layer Terraform repository for managing Harness IaCM workspaces across multiple application repos and environments using a centralized, registry-driven approach.

## Cross-Application Workspace Creation

This repo implements a **cross-application repository workspace creation** pattern. Instead of each application repo managing its own Harness IaCM workspace, this central Terraform repo discovers and provisions workspaces for all registered application repos automatically.

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  This Repo (terraform-complex-structure)                    │
│                                                             │
│  application_repos.yaml ─── list of app repos to manage    │
│         │                                                   │
│         ▼                                                   │
│  GitHub API ─── fetch workspaces/ folder from each repo    │
│         │                                                   │
│         ▼                                                   │
│  Decode YAML ─── parse workspace definitions                │
│         │                                                   │
│         ▼                                                   │
│  harness_platform_workspace ─── create IaCM workspaces     │
│  harness_platform_triggers  ─── create webhook triggers    │
└─────────────────────────────────────────────────────────────┘
```

1. **Registry file** (`modules/common/application_workspace_create/application_repos.yaml`) lists all application repos, their branches, and the Harness org/project they belong to:

    ```yaml
    repos:
      create_iacm_workspace:
        repo: create_iacm_workspace
        branch: main
        org_id: default
        project_id: Twilio
      app2_repo:
        repo: app2_repo
        branch: main
        org_id: default
        project_id: Twilioapp2
    ```

2. **Workspace discovery** — The module uses the GitHub API to list all `.yaml`/`.yml` files in each application repo's `workspaces/` directory. Each file defines one or more Harness IaCM workspaces with their provisioner settings, repository paths, connectors, and Terraform variables.

3. **Workspace provisioning** — For every discovered workspace definition, the module creates a `harness_platform_workspace` resource with the workspace's config (provisioner type/version, repository details, connector references, cost estimation, and Terraform variables).

4. **Webhook triggers** — The module automatically creates GitHub push triggers for:
   - **Each application repo** — so workspace definitions are re-applied whenever the app repo is updated
   - **This Terraform repo itself** — so adding a new repo to the registry triggers a re-run

### Adding a New Application Repo

To onboard a new application repo:

1. Add an entry to `modules/common/application_workspace_create/application_repos.yaml`:
    ```yaml
    repos:
      my_new_app:
        repo: my-new-app-repo    # GitHub repo name
        branch: main             # Branch to read workspace defs from
        org_id: default          # Harness org
        project_id: MyProject    # Harness project
    ```

2. In the application repo, create a `workspaces/` directory with YAML files defining the workspaces. Each YAML file should follow this structure:
    ```yaml
    workspaces:
      my_workspace:
        name: my-workspace
        identifier: my_workspace
        provisioner_type: terraform
        provisioner_version: 1.5.0
        repository: my-new-app-repo
        repository_branch: main
        repository_path: infra/
        repository_connector: twilio_connector
        cost_estimation_enabled: true
        terraform_variables:
          region:
            value: us-east-1
            value_type: string
    ```

3. Push to this repo — the webhook trigger will run the Harness IaCM pipeline to provision the new workspaces.

### Pipeline and Bootstrap

The entire flow is executed by the **`iacm_workspace_provision_iacm`** pipeline in Harness (org: `TwilioCentraOrg`, project: `Twilioinfra`). The pipeline runs an IaCM stage (`init` → `plan` → `apply`) against the **`bootstrapworkspace3`** workspace, which points to `modules/common/application_workspace_create` in this repo.

Harness provider credentials (`HARNESS_ENDPOINT`, `HARNESS_ACCOUNT_ID`, `HARNESS_PLATFORM_API_KEY`) are set as environment variables on the bootstrap workspace.

### Trigger Architecture

All triggers target the `iacm_workspace_provision_iacm` pipeline in the `TwilioCentraOrg/Twilioinfra` project:

- **`terraform_repo_push_trigger`** — fires on push to `main` of this repo (registry changes)
- **`{repo_key}_push_trigger`** — fires on push to each application repo's configured branch (workspace definition changes)

These triggers are managed by Terraform and should not be deleted manually from the Harness UI (Terraform will recreate them on next apply).

### Idempotency Across Repos

Every pipeline run reconciles **all** registered repos, not just the one that triggered it. This is safe because Terraform is idempotent — unchanged repos produce no diff and are skipped. For example, if team1 pushes a workspace change, team2 and team3's workspaces are evaluated but nothing changes for them. The only cost is slightly longer plan times as more repos are added (more GitHub API calls).

### Workspace Key Namespacing

Workspace keys in Terraform state are namespaced as `repo_key/workspace_key` to avoid collisions across repos. Within a single application repo, workspace keys must be unique across all YAML files (they are merged into a single map).

## Structure

### Modules

Reusable Terraform modules used by all environments:

- `modules/common/` - Environment-aware shared configuration
  - Provides environment-specific naming prefixes (tf_sandbox, tf_prod)
  - Common tags with environment label
- `modules/common/application_workspace_create/` - Cross-application workspace provisioning (see above)
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