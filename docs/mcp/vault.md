# MCP Integration Guidance — Vault Operations

This document establishes the safety boundaries, allowed actions, and dangerous commands for Model Context Protocol (MCP) servers integrated with HashiCorp Vault.

---

## 🛡️ Operational Boundaries

All AI operations executed through Vault MCP tools must conform to these access layers:

| Access Level | Operations Allowed | Safety Gates |
| :--- | :--- | :--- |
| **Read-Only** | Reading non-sensitive KV configuration paths, verifying secret paths exist. | None (safe to execute dynamically). |
| **Write/Modify** | Writing new cluster secrets during bootstrapping, updating configurations. | Pre-execution validation check + human-in-the-loop plan review. |
| **Destructive** | Deleting KV secret engines, purging client configurations, rolling back Vault policies. | **Strictly Forbidden** through automated MCP without explicit manual approval. |

---

## 🚫 Dangerous Operations & Constraints

1. **Secret Overwrites**:
   * Writing to a KV engine path without checking if secrets already exist will overwrite active keys and locks.
   * **Required**: Always read the path before writing. If secrets exist, append/merge rather than overwriting completely.
2. **Plaintext Secret Leaks**:
   * **NEVER** output retrieved secret values in CLI stdout or log files. MCP tools must consume secrets internally or redirect them securely.
3. **Vault Seal Status**:
   * If Vault is sealed, MCP operations will fail. Alert the operator immediately instead of attempting to parse empty responses as failures.
