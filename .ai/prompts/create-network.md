# Playbook Prompt — Create a New Network Subnet

Use this prompt to instruct an AI assistant to adjust IPAM blocks or add a new subnet range for internal VM allocation.

---

## 🎯 Objective
Configure new IP subnets for OpenStack VPC router interfaces and Kubernetes pod/service networks.

---

## 📋 Required Context
1. Which environment needs modification? (`staging` or `prod`).
2. What are the target CIDR ranges? E.g.:
   * VPC internal subnet: `10.30.1.0/24`
   * Pod network: `10.30.8.0/21`
   * Service network: `10.30.16.0/21`

---

## 🛠️ Step-by-Step Instructions for the AI

1. **Locate Environment Settings**:
   Navigate to the environment configuration file (e.g. [staging/env.hcl](file:///live/staging/env.hcl) or [prod/env.hcl](file:///live/prod/env.hcl)).
2. **Modify Subnet Variables**:
   * Change `internal_cidr` to target value.
   * Change `pod_subnets` to target list.
   * Change `service_subnets` to target list.
3. **Verify IPAM Boundaries**:
   Confirm that the new subnets do not overlap with any other environment CIDR blocks to maintain security isolation.
4. **HCL Validation**:
   `terragrunt hclfmt --terragrunt-check`
5. **Dry-Run Plan**:
   `terragrunt run --all plan --non-interactive`

---

## 🔍 Validation Checklist
- Confirm router interfaces are updated correctly in the plan.
- Check Talos user data changes in the plan, verifying that podSubnets and serviceSubnets certSANs match the new CIDR blocks.
