############################## OPENSTACK INSTANCES ############################

resource "openstack_compute_instance_v2" "controlplane" {
  count           = var.cp_count
  name            = "${var.project_name}-${var.env}-cp-${count.index + 1}"
  image_name      = var.image_name
  flavor_name     = var.cp_flavor
  key_pair        = var.keypair_name
  security_groups = var.secgroup_ids
  user_data       = var.cp_user_data

  network {
    uuid = var.internal_net_id
  }
}

resource "openstack_compute_instance_v2" "worker" {
  count           = var.worker_count
  name            = "${var.project_name}-${var.env}-worker-${count.index + 1}"
  image_name      = var.image_name
  flavor_name     = var.worker_flavor
  key_pair        = var.keypair_name
  security_groups = var.secgroup_ids
  user_data       = var.worker_user_data

  network {
    uuid = var.internal_net_id
  }
}

###############################################################################
