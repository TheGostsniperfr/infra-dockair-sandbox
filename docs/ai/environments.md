# AI Documentation — Environments Configuration

This document outlines the topology, parameter values, and sizing of staging and production environments in the Dockair Sandbox infrastructure.

---

## 🛠️ Staging Environment (`live/staging/`)

Staging is designed for pre-production validation, linting tests, and lightweight deployments.

### Parameters (`env.hcl`)
* **Project Name**: `dockair-sandbox`
* **Environment Name**: `staging`
* **Internal VM Subnet**: `10.20.1.0/24`
* **Pod Subnets (Cilium)**: `10.20.8.0/21`
* **Service Subnets**: `10.20.16.0/21`

### Sizing & Topology
* **Control Plane Node**: 1 instance, flavor `m1.medium`
* **Worker Nodes**: 3 instances, flavor `m1.small`
* **Security Groups**: `sg-base`, `sg-talos`, `sg-k3s`

---

## 🚀 Production Environment (`live/prod/`)

Production represents the physical execution environment for customer workloads.

### Parameters (`env.hcl`)
* **Project Name**: `dockair-sandbox`
* **Environment Name**: `prod`
* **Internal VM Subnet**: `10.10.1.0/24`
* **Pod Subnets (Cilium)**: `10.10.8.0/21`
* **Service Subnets**: `10.10.16.0/21`

### Sizing & Topology
* **Control Plane Node**: 1 instance, flavor `m1.medium`
* **Worker Nodes**: 3 instances, flavor `m1.medium`
* **Security Groups**: `sg-base`, `sg-talos`, `sg-k3s`

---

## ⚙️ Shared Global Variables (`live/common.hcl`)

Shared parameters that remain consistent across both staging and production:
* **Talos OS version**: `v1.13.3`
* **OpenStack Image**: `talos-v1.13.3`
* **Admin Keypair**: `3-istor-cloud-kp-admin`
