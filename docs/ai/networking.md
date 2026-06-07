# AI Documentation — Network & IPAM Architecture

This document describes the OpenStack networking configuration and IP address management (IPAM) matrix for the Dockair Sandbox infrastructure.

---

## 🌐 Subnet Allocation Matrix

Staging and production use non-overlapping CIDR blocks to prevent routing conflicts and enable VPN/transit-gateway integration.

| Environment | Block Type | CIDR Range | Description |
| :--- | :--- | :--- | :--- |
| **Production** | VM Instances VPC | `10.10.1.0/24` | OpenStack VM private network |
| **Production** | Kubernetes Pods | `10.10.8.0/21` | Cilium overlay (non-kube-proxy) |
| **Production** | Kubernetes Services | `10.10.16.0/21` | Virtual ClusterIPs |
| | | | |
| **Staging** | VM Instances VPC | `10.20.1.0/24` | OpenStack VM private network |
| **Staging** | Kubernetes Pods | `10.20.8.0/21` | Cilium overlay (non-kube-proxy) |
| **Staging** | Kubernetes Services | `10.20.16.0/21` | Virtual ClusterIPs |

---

## 🛠️ OpenStack Networking Components

1. **External Network (`ext-net`)**: 
   * Fetched via `openstack_networking_network_v2` data source using `floating_ip_pool = "ext-net"`.
   * Serves as the public gateway for router SNAT and Floating IP allocation.
2. **Private Network**:
   * Named `${var.project_name}-internal-net`.
   * Enforces DHCP enabled for IP assignment on instance boots.
3. **Subnet**:
   * Named `${var.project_name}-internal-subnet`.
   * Gateway IP set to `cidrhost(subnet_cidr, 1)` (e.g. `10.10.1.1` or `10.20.1.1`).
   * DNS Servers set to `["1.1.1.1", "8.8.8.8"]`.
4. **Router**:
   * Named `${var.project_name}-router` with SNAT enabled (`enable_snat = true`).
   * Creates a router interface linking the private subnet to the public external network pool.
5. **Floating IP (FIP)**:
   * Dynamically reserved from the pool `ext-net`.
   * Associated to the Octavia Load Balancer VIP port to expose the Talos/K8s APIs publicly.
