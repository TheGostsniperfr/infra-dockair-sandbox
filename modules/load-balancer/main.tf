############################# LOAD BALANCER CORE ##############################

resource "openstack_lb_loadbalancer_v2" "api_lb" {
  name           = "${var.project_name}-api-lb"
  vip_subnet_id  = var.subnet_id
  admin_state_up = true
}

###############################################################################

########################## KUBERNETES API (Port 6443) #########################

resource "openstack_lb_listener_v2" "k8s_api" {
  name            = "${var.project_name}-k8s-api-listener"
  protocol        = "TCP"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.api_lb.id
}

resource "openstack_lb_pool_v2" "k8s_api" {
  name        = "${var.project_name}-k8s-api-pool"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.k8s_api.id
}

resource "openstack_lb_monitor_v2" "k8s_api" {
  name        = "${var.project_name}-k8s-api-monitor"
  pool_id     = openstack_lb_pool_v2.k8s_api.id
  type        = "TCP"
  delay       = 10
  timeout     = 5
  max_retries = 3
}

resource "openstack_lb_member_v2" "k8s_api_members" {
  count         = length(var.control_plane_ips)
  pool_id       = openstack_lb_pool_v2.k8s_api.id
  address       = var.control_plane_ips[count.index]
  protocol_port = 6443
  subnet_id     = var.subnet_id
}

###############################################################################

###################### TALOS MANAGEMENT API (Port 50000) ######################

resource "openstack_lb_listener_v2" "talos_api" {
  name            = "${var.project_name}-talos-api-listener"
  protocol        = "TCP"
  protocol_port   = 50000
  loadbalancer_id = openstack_lb_loadbalancer_v2.api_lb.id
}

resource "openstack_lb_pool_v2" "talos_api" {
  name        = "${var.project_name}-talos-api-pool"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.talos_api.id
}

resource "openstack_lb_monitor_v2" "talos_api" {
  name        = "${var.project_name}-talos-api-monitor"
  pool_id     = openstack_lb_pool_v2.talos_api.id
  type        = "TCP"
  delay       = 10
  timeout     = 5
  max_retries = 3
}

resource "openstack_lb_member_v2" "talos_api_members" {
  count         = length(var.control_plane_ips)
  pool_id       = openstack_lb_pool_v2.talos_api.id
  address       = var.control_plane_ips[count.index]
  protocol_port = 50000
  subnet_id     = var.subnet_id
}

###############################################################################

########################### FLOATING IP ASSOCIATION ############################

resource "openstack_networking_floatingip_associate_v2" "lb_fip_assoc" {
  floating_ip = var.fip_address
  port_id     = openstack_lb_loadbalancer_v2.api_lb.vip_port_id
}

###############################################################################
