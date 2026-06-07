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

###############################################################################
