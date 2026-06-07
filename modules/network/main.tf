############################### External Network ##############################

data "openstack_networking_network_v2" "ext_net" {
  name = var.floating_ip_pool
}

###############################################################################

############################### Internal Network ##############################

resource "openstack_networking_network_v2" "internal_net" {
  name           = "${var.project_name}-internal-net"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "internal_subnet" {
  name            = "${var.project_name}-internal-subnet"
  network_id      = openstack_networking_network_v2.internal_net.id
  cidr            = var.internal_cidr
  ip_version      = 4
  gateway_ip      = cidrhost(var.internal_cidr, 1)
  dns_nameservers = var.dns_servers
  enable_dhcp     = true
}

resource "openstack_networking_router_v2" "router" {
  name        = "${var.project_name}-router"
  description = "The router for ${var.project_name} project"

  external_network_id = data.openstack_networking_network_v2.ext_net.id
  # tenant_id           = openstack_identity_project_v3.project_1.id

  admin_state_up = true
  enable_snat    = true

  # external_fixed_ip {
  #   subnet_id  = openstack_networking_subnet_v2.internal_network_subnet.id
  #   ip_address = cidrhost(var.internal_network_cidr, 1)
  # }

  vendor_options {
    set_router_gateway_after_create = true
  }
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.internal_subnet.id
}

###############################################################################

########################### FLOATING IP RESERVATION ###########################

resource "openstack_networking_floatingip_v2" "api_fip" {
  pool = var.floating_ip_pool
}

################################################################################

################################ SECURITY GROUPS ###############################
# Define isolated security groups for baseline network, Talos API, and Kubernetes control.

resource "openstack_networking_secgroup_v2" "sg_base" {
  name        = "${var.project_name}-${var.env}-sg-base"
  description = "Baseline security group for all nodes in the cluster"
}

resource "openstack_networking_secgroup_v2" "sg_talos" {
  name        = "${var.project_name}-${var.env}-sg-talos"
  description = "Talos API and management security group"
}

resource "openstack_networking_secgroup_v2" "sg_k3s" {
  name        = "${var.project_name}-${var.env}-sg-k3s"
  description = "Kubernetes CNI and control plane security group"
}

################################################################################

############################# SECURITY GROUP RULES #############################
# Define access rules for internal cluster communication, external admin API access, and CNI overlay routing.

# sg-base: ICMP (Ping)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.sg_base.id
  remote_ip_prefix  = "0.0.0.0/0"
}

# sg-talos: Talos Control Plane API (50000)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_talos_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50000
  security_group_id = openstack_networking_secgroup_v2.sg_talos.id
  remote_ip_prefix  = "0.0.0.0/0"
}

# sg-talos: Talos Node Daemon API (50001)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_talos_daemon" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50001
  port_range_max    = 50001
  security_group_id = openstack_networking_secgroup_v2.sg_talos.id
  remote_ip_prefix  = var.internal_cidr
}

# sg-talos: etcd Peer/Client ports (2379-2380)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  security_group_id = openstack_networking_secgroup_v2.sg_talos.id
  remote_ip_prefix  = var.internal_cidr
}

# sg-k3s: Kubernetes API Server (6443)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_k8s_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  security_group_id = openstack_networking_secgroup_v2.sg_k3s.id
  remote_ip_prefix  = "0.0.0.0/0"
}

# sg-k3s: Kubelet API (10250)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  security_group_id = openstack_networking_secgroup_v2.sg_k3s.id
  remote_ip_prefix  = var.internal_cidr
}

# sg-k3s: VXLAN CNI overlay (8472 UDP)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_vxlan" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  security_group_id = openstack_networking_secgroup_v2.sg_k3s.id
  remote_ip_prefix  = var.internal_cidr
}

# sg-k3s: Cilium Agent Health Check (4240 TCP)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_cilium_health" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 4240
  port_range_max    = 4240
  security_group_id = openstack_networking_secgroup_v2.sg_k3s.id
  remote_ip_prefix  = var.internal_cidr
}

# sg-k3s: BGP port (179 TCP)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_bgp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 179
  port_range_max    = 179
  security_group_id = openstack_networking_secgroup_v2.sg_k3s.id
  remote_ip_prefix  = var.internal_cidr
}

# sg-k3s: Allow all internal communication between members of the cluster
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = ""
  security_group_id = openstack_networking_secgroup_v2.sg_k3s.id
  remote_ip_prefix  = var.internal_cidr
}

################################################################################

