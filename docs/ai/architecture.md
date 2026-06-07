# AI Documentation — Codebase Architecture

This document explains the code organization, separation of concerns, and DRY principles implemented in the Dockair Sandbox infrastructure repository.

---

## 🏗️ Reusable Modules (`modules/`)

The `modules/` directory contains pure, generic, and stateless Terraform modules. They do not maintain backend configurations or environment-specific values. They accept inputs via variables and export outputs.

1. **`network`**: Creates private VPC network, subnets, routers, router interfaces to external nets, and reserves a public Floating IP.
2. **`talos-config`**: Generates Talos OS PKI and secrets, handles custom patches (DNS, label, scheduler), compiles machine config templates (control plane & worker), and stores credentials in HashiCorp Vault.
3. **`compute`**: provisions control plane and worker VM instances on OpenStack and passes Talos user data to them.
4. **`load-balancer`**: Configures Octavia Load Balancer, listeners, pools, health monitors, and registers control plane members for ports `6443` (K8s API) and `50000` (Talos API).
5. **`cluster-bootstrap`**: Executes the Talos API etcd bootstrap command on the first control plane node.

---

## 🚀 Deployment Layer (`live/`)

The `live/` directory manages environment instantiations (staging and production) using Terragrunt.

### Root Orchestrator (`live/root.hcl`)
The entry point configuration for Terragrunt. It:
* Loads environment variables from the nearest parent `env.hcl` and `common.hcl`.
* Dynamically configures the AWS S3 state backend, partitioning keys using `${local.env}/${path_relative_to_include()}`.
* Generates `provider.tf` files for `openstack`, `vault`, and `talos` with pinned versions.
* Copies Terraform lockfiles back to the source directory (`copy_terraform_lock_file = true`).

### Shared Templates (`live/_env/`)
Defines the blueprints for all environments. This separates Terragrunt source directories and inputs from concrete environment variables, keeping configurations DRY.
* `network.hcl`, `compute.hcl`, `load-balancer.hcl`, `talos-config.hcl`, `cluster-bootstrap.hcl` import module definitions from `modules/` and wire inputs.

### Concrete Configurations (`live/staging/` & `live/prod/`)
Physical deployment folders. Each subdirectory (e.g. `compute/terragrunt.hcl`) is minimal:
* Includes `root.hcl` to initialize provider/state.
* Includes `_env/<component>.hcl` to import standard arguments.
* Defines env-specific inputs (flavors, node counts) or overrides.

---

## 🔒 Plaintext State Security Risks & Mitigations

### The Security Risk
Although the AWS S3 state backend is encrypted in transit and at rest (`encrypt = true`), the Terraform remote state files (`terraform.tfstate`) store all outputs, resources, and variables in plaintext. In this codebase:
* The `modules/talos-config` module invokes the `talos_machine_secrets` provider.
* The generated Talos PKI keys, certificates, and cluster bootstrap tokens are written in plaintext to the remote state file (`terraform.tfstate`) in the S3 bucket (`3-istor-tf-infra-aws`).

Anyone with read permissions to the S3 bucket or DynamoDB lock table can retrieve the full root credentials for the Talos cluster and gain administrator control over the Kubernetes nodes.

### Mitigations & Safeguards
1. **Least-Privilege IAM Access**: Enforce strict IAM policies restricting read/write access to the `3-istor-tf-infra-aws` bucket and the corresponding DynamoDB state lock table to authorized OIDC CI/CD roles and cluster administrators only.
2. **State Encryption at Rest (Future Upgrade)**: If OpenTofu or Terraform 1.6+ is adopted in the future, we should configure the native state encryption features (e.g. encrypting the state files client-side using AWS KMS keys before uploading them to the remote S3 backend).

