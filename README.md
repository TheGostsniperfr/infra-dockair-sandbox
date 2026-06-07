# Dockair Sandbox Infrastructure

This repository manages the cloud infrastructure for the Dockair Sandbox environment on OpenStack using a **Terragrunt + Terraform** DRY (Don't Repeat Yourself) architecture.

## 🧠 Architectural Overview

For a detailed visual analysis of our infrastructure, please refer to the dedicated documentation:
*   [Global Dependency Graph](docs/architecture/global-dependency-graph.md) — Orchestration DAG, module dependencies, and external systems integration.
*   [Networking & Security](docs/architecture/networking-and-security.md) — OpenStack network topology, security groups port matrix, and Cilium CNI configurations.
*   [Secrets Management](docs/architecture/secrets-management.md) — Cluster PKI lifecycle, HashiCorp Vault kvv2 storage, and talosconfig retrieval.

This project is split into two logical layers:
1. **`modules/`**: Contains pure, reusable, and parameterizable Terraform modules. These modules do not contain any hardcoded environment variables or state configurations.
2. **`live/`**: Contains the Terragrunt configurations that instantiate the modules. It represents the concrete environments (`staging` and `prod`) and handles backend state management.

```text
.
├── .github/
│   └── workflows/
│       └── terragrunt-pipeline.yml     # Automated CI/CD pipeline (Lint, Plan, Apply)
│
├── live/                               # Terragrunt deployment layer
│   ├── root.hcl                        # Root configuration (handles remote state generation & providers)
│   ├── common.hcl                      # Shared global variables (Talos versions, image names, keypairs)
│   │
│   ├── _env/                           # Parent templates (DRY factorized configurations)
│   │   ├── network.hcl                 # Common template for the OpenStack VPC, Subnets & FIP
│   │   ├── talos-config.hcl            # Common template for the Talos OS & secrets generation
│   │   ├── compute.hcl                 # Common template for the VM instances & cluster bootstrap
│   │   └── load-balancer.hcl           # Common template for the API Load Balancer
│   │
│   ├── staging/                        # Staging Environment
│   │   ├── env.hcl                     # Staging variables (VM sizes, CIDRs)
│   │   ├── network/                    # Deploys staging VPC & reserves Floating IP
│   │   ├── talos-config/               # Deploys staging configs (1 CP, 3 workers)
│   │   ├── compute/                    # Deploys staging VMs (1 CP, 3 workers)
│   │   └── load-balancer/              # Deploys staging API Load Balancer
│   │
│   └── prod/                           # Production Environment
│       ├── env.hcl                     # Production variables (VM sizes, CIDRs)
│       ├── network/                    # Deploys production VPC & reserves Floating IP
│       ├── talos-config/               # Deploys production configs (1 CP, 3 workers)
│       ├── compute/                    # Deploys production VMs (1 CP, 3 workers)
│       └── load-balancer/              # Deploys production API Load Balancer
│
└── modules/                            # Reusable raw Terraform code (No state)
    ├── network/                        # Manages private VPC, subnets, routing & FIP allocation
    ├── talos-config/                   # Manages secrets generation, Vault storage & machine configurations
    │   └── patches/                    # Directory for static Talos patches (NTP, DNS, labels)
    ├── compute/                        # Manages VM creation & triggers Talos bootstrap
    └── load-balancer/                  # Manages public VIP & API Load Balancer (ports 6443 & 50000)
```

## 📁 Directory Purpose

### `/live/root.hcl` (The Orchestrator)
The root `root.hcl` file is evaluated globally. Its primary responsibility is to dynamically generate the remote state storage configuration (e.g., S3/Swift bucket) and the provider configurations (OpenStack, Vault, Talos) based on the running directory. This ensures each sub-component has an isolated state file.

### `/live/common.hcl` (Global Settings)
Contains shared settings like software versions (e.g., Talos version) and keypairs that remain consistent across both staging and production environments.

### `/live/_env/` (The Blueprints)
This directory contains "parent" HCL files. Instead of repeating the source URL, inputs, and settings for each environment, we write the blueprint once here. The environments then inherit from these files.

### `/live/staging/` & `/live/prod/` (The Concrete Deployments)
These directories represent the physical infrastructure. The `terragrunt.hcl` files inside them inherit the configuration from `/live/_env/` and only override parameters specific to their environment (defined in `env.hcl` or explicitly as local inputs, such as the VM sizes). Both staging and production utilize a topology of 1 control plane node and 3 worker nodes.

### `/modules/` (The Engine)
This is where the pure Terraform code lives.
*   **`network/`**: Creates the network boundaries.
*   **`load-balancer/`**: Provisions the public-facing Load Balancer to distribute traffic to the control plane nodes.
*   **`talos-cluster/`**: Generates cryptographic secrets, sets up the VM instances, and injects the Talos configuration patches. All patch templates (like `talos-config-patch.yaml`) live inside this module's `patches/` folder to avoid relative path compilation errors in Terragrunt cache.

## 🌐 Network & IP Address Management (IPAM)

To prevent IP conflicts and allow seamless routing between environments (e.g., via VPN or transit gateways), we enforce a strict, non-overlapping IP allocation matrix.

| Environment | Component | CIDR Block | Usable IPs | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Production**| VMs (OpenStack) | `10.10.1.0/24` | 254 | HA Virtual machines |
| **Production**| K8s Pods (Cilium) | `10.10.8.0/21` | 2048 | Internal container network |
| **Production**| K8s Services | `10.10.16.0/21` | 2048 | Internal virtual services |
| | | | | |
| **Staging** | VMs (OpenStack) | `10.20.1.0/24` | 254 | Virtual machines |
| **Staging** | K8s Pods (Cilium) | `10.20.8.0/21` | 2048 | Internal container network |
| **Staging** | K8s Services | `10.20.16.0/21` | 2048 | Internal virtual services |

### Key Rules:
1. **No Overlaps**: No two environments or components must share the same subnet.
2. **Environment Separation**: Production is strictly isolated within the `10.10.0.0/16` subnet, and Staging within `10.20.0.0/16`.
3. **Cilium Routing**: K8s Pod CIDRs must be configured in Talos and Cilium to ensure standard eBPF routing without kube-proxy.
