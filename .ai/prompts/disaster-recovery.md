# Playbook Prompt — Infrastructure Disaster Recovery Plan

Use this prompt to instruct an AI assistant to recover the sandbox infrastructure from state corruption, service outages, or total cluster loss.

---

## 🎯 Objective
Re-deploy the sandbox cluster, restore routing interfaces, and synchronize secrets back to Vault.

---

## 📋 Required Context
1. What is the target recovery environment? (`staging` or `prod`).
2. Has the remote state S3 bucket been corrupted, or is this a total rebuild from scratch?

---

## 🛠️ Step-by-Step Instructions for the AI

1. **State Recovery (If State is Corrupted)**:
   * Navigate to the S3 remote state bucket history and attempt to roll back the `.tfstate` objects to the last known healthy version.
   * If the state is unrecoverable, clear the lock table in DynamoDB:
     `terragrunt force-unlock <lock-id>`
2. **Total Rebuild Flow (DAG Order)**:
   If rebuilding the cluster from scratch, execute modules sequentially to avoid dependency failures:
   * **Phase 1: VPC Network**
     `cd live/<env>/network && terragrunt apply --non-interactive`
   * **Phase 2: PKI Talos Config**
     `cd live/<env>/talos-config && terragrunt apply --non-interactive`
     *(This generates the cluster secrets and uploads them to Vault)*
   * **Phase 3: Compute Nodes**
     `cd live/<env>/compute && terragrunt apply --non-interactive`
   * **Phase 4: API Load Balancer**
     `cd live/<env>/load-balancer && terragrunt apply --non-interactive`
   * **Phase 5: Cluster Bootstrapping**
     `cd live/<env>/cluster-bootstrap && terragrunt apply --non-interactive`
3. **Secret Verification**:
   Query Vault to verify that Talos machine secrets are present:
   `vault read kvv2/<project_name>/<env>/talos/cluster-secrets`
4. **Validation Test**:
   Test cluster health:
   `talosctl --endpoints <lb-ip> --nodes <node-ip> health`
