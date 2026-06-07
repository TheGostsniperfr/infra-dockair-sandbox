# Playbook Prompt — Upgrade Talos OS Version

Use this prompt to instruct an AI assistant to upgrade the Talos operating system version across staging and production.

---

## 🎯 Objective
Upgrade the Talos version and OpenStack Glance image reference globally.

---

## 📋 Required Context
1. What is the target Talos version? (e.g. `v1.14.0`).
2. What is the matching OpenStack image name? (e.g. `talos-v1.14.0`).

---

## 🛠️ Step-by-Step Instructions for the AI

1. **Locate Global Settings**:
   Navigate to the shared global variables file: [live/common.hcl](file:///live/common.hcl).
2. **Update Versions**:
   * Modify `talos_version = "<target_version>"` in `locals`.
   * Modify `image_name = "<target_image>"` in `locals` (this image must exist in OpenStack Glance).
3. **Check Root Provider Versions**:
   Open [live/root.hcl](file:///live/root.hcl) and check the `generate "provider"` block. If the new Talos version requires a newer Siderolabs provider version, update the version requirement:
   ```hcl
   talos = {
     source  = "siderolabs/talos"
     version = "~> <target_provider_version>"
   }
   ```
4. **HCL Validation**:
   `terragrunt hclfmt --terragrunt-check`
5. **Dry-Run Plan**:
   `terragrunt run --all plan --non-interactive`

---

## 🔍 Validation Checklist
- Check that the output plan shows instances being updated or replaced (depending on OpenStack reboot/recreation flags) with the new Glance image name.
- Verify Talos provider binaries download successfully.
