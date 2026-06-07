# Playbook Prompt — Add a Worker Node to Cluster

Use this prompt to instruct an AI coding assistant to scale the worker nodes in the staging or production environments.

---

## 🎯 Objective
Scale the worker node count in the specified environment (`staging` or `prod`).

---

## 📋 Required Context
1. Which environment needs scaling? (Default: `staging`).
2. What is the target worker count? (Current setting is 3).

---

## 🛠️ Step-by-Step Instructions for the AI

1. **Locate Environment Settings**:
   Navigate to the target environment's folder (e.g. [staging/compute/terragrunt.hcl](file:///live/staging/compute/terragrunt.hcl) or [prod/compute/terragrunt.hcl](file:///live/prod/compute/terragrunt.hcl)).
2. **Update VM Count**:
   Locate the `inputs` block and modify `worker_count = <target_count>`.
3. **Synchronize OS Configurations**:
   Open [staging/talos-config/terragrunt.hcl](file:///live/staging/talos-config/terragrunt.hcl) or [prod/talos-config/terragrunt.hcl](file:///live/prod/talos-config/terragrunt.hcl) and update `worker_count = <target_count>` to keep the Talos PKI generation settings synchronized.
4. **HCL Validation**:
   Run format checks:
   `terragrunt hcl fmt --check`
5. **Validation Dry-Run**:
   Run planning verification:
   `terragrunt run --all plan --non-interactive`

---

## 🔍 Validation Checklist
- Ensure `worker_count` is updated in both `compute` and `talos-config` HCL files.
- The plan output must show OpenStack instance resources being added without recreating existing control plane instances.
