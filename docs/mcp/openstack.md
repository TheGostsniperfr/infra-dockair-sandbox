# MCP Integration Guidance — OpenStack Operations

This document establishes the safety boundaries, allowed actions, and dangerous commands for Model Context Protocol (MCP) servers integrated with OpenStack.

---

## 🛡️ Operational Boundaries

All AI operations executed through OpenStack MCP tools must conform to these access layers:

| Access Level | Operations Allowed | Safety Gates |
| :--- | :--- | :--- |
| **Read-Only** | Listing networks, subnets, routers, compute flavors, Glance images, and active instances. | None (safe to execute dynamically). |
| **Write/Modify** | Reserving floating IPs, scaling instance VM counts, creating security group rules. | Pre-execution validation check + human-in-the-loop plan review. |
| **Destructive** | Deleting router interfaces, destroying networks, terminating VM nodes. | **Strictly Forbidden** through automated MCP without explicit manual approval. |

---

## 🚫 Dangerous Operations & Constraints

1. **VPC Deletions**:
   * **NEVER** delete an OpenStack private network or subnet while instances are attached. This will leave the state file in an inconsistent lock.
2. **Compute Instance Recreations**:
   * Changing critical VM parameters (like Glance image names or network attach UUIDs) triggers a complete resource recreation (destroy-and-rebuild) in OpenStack.
   * **Required**: Always warn the operator before applying modifications that trigger VM deletion and replacement.
3. **Flavors & Sizing**:
   * Confirm that flavor updates are supported by the OpenStack compute pool quota before executing changes.

---

## 🆘 Recovery Procedures

If an OpenStack resource is accidentally corrupted or deleted during an MCP operation:
1. Halt all executing tools immediately.
2. Inspect the S3 state file locks.
3. Use the `.ai/prompts/disaster-recovery.md` playbook to trigger sequential recreation.
