# MCP Integration Guidance — Talos OS Operations

This document establishes the safety boundaries, allowed actions, and dangerous commands for Model Context Protocol (MCP) servers integrated with Talos Linux.

---

## 🛡️ Operational Boundaries

All AI operations executed through Talos MCP tools must conform to these access layers:

| Access Level | Operations Allowed | Safety Gates |
| :--- | :--- | :--- |
| **Read-Only** | Running `talosctl get status`, reading system configs, checking system extensions, verifying node status. | None (safe to execute dynamically). |
| **Write/Modify** | Upgrading Talos configs, applying node configuration patches, updating node labels. | Pre-execution validation check + human-in-the-loop plan review. |
| **Destructive** | Bootstrapping etcd (`talosctl bootstrap`), rebooting control planes, upgrading host OS images. | **Strictly Forbidden** through automated MCP without explicit manual approval. |

---

## 🚫 Dangerous Operations & Constraints

1. **Re-bootstrap Cluster**:
   * **NEVER** run `talosctl bootstrap` on an already running cluster. This can corrupt the etcd database and destroy cluster state.
2. **Control Plane Upgrades**:
   * Running OS upgrades on control plane nodes must be done sequentially (one node at a time) to maintain API availability.
3. **Draft OS Image Overwrites**:
   * Confirm that the image factory configuration URL contains valid system extensions before deploying.

---

## 🆘 Recovery Procedures

If a Talos node enters a crashloop or fails to boot:
1. Halt all executing tools.
2. Retrieve logs using `talosctl logs` or console redirection if available on OpenStack.
3. If etcd is corrupted, trigger the disaster recovery process (.ai/prompts/disaster-recovery.md) using the backup secrets stored in Vault.
