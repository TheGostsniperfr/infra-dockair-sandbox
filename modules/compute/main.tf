################################ NEUTRON PORTS #################################
# Explicitly create Neutron ports for control plane and worker instances.
# This enables granular control over security groups, port security, and allowed IP pairs.

resource "openstack_networking_port_v2" "cp_port" {
  count              = var.cp_count
  name               = "${var.project_name}-${var.env}-cp-port-${count.index + 1}"
  network_id         = var.internal_net_id
  admin_state_up     = true
  security_group_ids = var.secgroup_ids
}

resource "openstack_networking_port_v2" "worker_port" {
  count              = var.worker_count
  name               = "${var.project_name}-${var.env}-worker-port-${count.index + 1}"
  network_id         = var.internal_net_id
  admin_state_up     = true
  security_group_ids = var.secgroup_ids
}

################################################################################

############################## OPENSTACK INSTANCES ############################

resource "openstack_compute_instance_v2" "controlplane" {
  count       = var.cp_count
  name        = "${var.project_name}-${var.env}-cp-${count.index + 1}"
  image_name  = var.image_name
  flavor_name = var.cp_flavor
  key_pair    = var.keypair_name
  user_data   = var.cp_user_data

  network {
    port = openstack_networking_port_v2.cp_port[count.index].id
  }
}

resource "openstack_compute_instance_v2" "worker" {
  count       = var.worker_count
  name        = "${var.project_name}-${var.env}-worker-${count.index + 1}"
  image_name  = var.image_name
  flavor_name = var.worker_flavor
  key_pair    = var.keypair_name
  user_data   = var.worker_user_data

  network {
    port = openstack_networking_port_v2.worker_port[count.index].id
  }
}

###############################################################################
