# AGENTS.md — Repository AI Developer Guide

Welcome, AI Coding Agent. This file serves as your system instructions and context entry point for this repository. It defines repository boundaries, code style invariants, testing pipelines, and architectural rules you **must** follow.

---

## 📋 Repository Overview

This repository manages the cloud infrastructure for the **Dockair Sandbox** on OpenStack using an immutable operating system (**Talos OS**), a secrets engine (**HashiCorp Vault**), and a DRY infrastructure-as-code orchestrator (**Terragrunt + Terraform**).

### Directory Structure
```text
.
├── .github/
│   └── workflows/
│       └── terragrunt-pipeline.yml     # Automated CI/CD pipeline (Lint, Scan, Plan, Apply)
│
├── .cursor/rules/                      # Domain-specific Cursor rule files (.mdc)
│
├── .gemini/skills/                     # Gemini/Antigravity custom agent skills
│
├── live/                               # Terragrunt deployment layer (concrete settings)
│   ├── root.hcl                        # Root config (remote state & provider generator)
│   ├── common.hcl                      # Shared global versions and parameters
│   ├── _env/                           # Blueprints/templates for infrastructure modules
│   ├── staging/                        # Staging environment (1 CP / 3 Workers)
│   └── prod/                           # Production environment (1 CP / 3 Workers)
│
├── modules/                            # Reusable, parameterizable Terraform code (no state)
│   ├── network/                        # VPC, Subnetting, Router, FIP
│   ├── compute/                        # VMs, OS boot trigger
│   ├── load-balancer/                  # Octavia Load Balancer (port 6443 / 50000)
│   ├── talos-config/                   # Talos PKI, node patches, Vault Generic Secrets
│   └── cluster-bootstrap/              # Talos cluster bootstrap API execution
│
└── docs/
    ├── ai/                             # Detailed documentation consumed by AI agents
    └── mcp/                            # Model Context Protocol security boundaries
```

---

## 🚫 Critical Boundaries & Invariants

You **must** respect the following boundaries. Violating these rules will result in CI failure or security blocks:

1. **Secrets Management**:
   * **NEVER** write or commit generated secrets, API tokens, passwords, private keys (`.pem`, `.key`), or Vault tokens to Git.
   * All cluster secrets must be handled dynamically through Vault integration in the `talos-config` module.
2. **Untracked Cache Files**:
   * **NEVER** modify files inside `.terragrunt-cache/` or `.terraform/` directories.
   * **NEVER** check in `.terragrunt-cache/` or `.terraform/` to Git. Ensure they are excluded by `.gitignore`.
3. **No Local State**:
   * Remote state is managed in an S3 backend (`3-istor-tf-infra-aws`). Do not run or commit local `.tfstate` configurations.
4. **DRY Architecture**:
   * Reusable code block templates belong under `live/_env/*.hcl`.
   * Environment overrides (like flavors or worker counts) belong in `live/staging/env.hcl` or `live/prod/env.hcl` (or explicitly under `inputs` inside child `terragrunt.hcl` configurations).

---

## ✍️ Code Style & HCL Commenting Conventions

When editing HCL/Terragrunt configurations, always apply the following formatting:

* **Separators**: Use standard block headers:
  `############################# <TITLE> ##############################`
* **Commentary Rule**: Explain the **why**, not the "what". Remove obvious comments like `# Declares source path` or `# Parent includes`.
* **Spacing**: Place exactly one blank line (`\n`) between the description/comment block and the HCL block.

### Example:
```hcl
################################# DEPENDENCIES #################################
# Inject mock values during plan/validate to bypass missing state on bootstrapping.

dependency "network" {
  config_path = "${get_terragrunt_dir()}/../network"
}

################################################################################
```

---

## 🔒 Lockfile Handling

Provider locks (`.terraform.lock.hcl`) are automatically tracked. The root `live/root.hcl` is configured with `copy_terraform_lock_file = true` inside its `terraform` block. Ensure this block remains intact so provider versions are locked in Git.

---

## 🧪 Verification & Commands

Before completing your tasks, run syntax verification tests:
* Staging validation:
  `cd live/staging && terragrunt run --all plan --non-interactive`
* Production validation:
  `cd live/prod && terragrunt run --all plan --non-interactive`

---

## 📖 Context Retrieval
For deeper details, consult:
* Detailed AI Docs: [docs/ai/](docs/ai/)
* Reusable prompts/playbooks: [.ai/prompts/](.ai/prompts/)
* MCP safety boundaries: [docs/mcp/](docs/mcp/)
