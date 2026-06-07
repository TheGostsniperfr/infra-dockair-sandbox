######################### LOCAL PATCHES LOADER & LOGIC ########################

locals {
  patch_files    = fileset("${path.module}/patches", "*.yaml")
  static_patches = [for file in local.patch_files : file("${path.module}/patches/${file}")]

  allow_scheduling = var.worker_count == 0 ? true : false
  scheduling_patch = yamlencode({
    cluster = {
      allowSchedulingOnControlPlanes = local.allow_scheduling
    }
  })

  dynamic_network_patch = yamlencode({
    machine = {
      certSANs = [var.lb_public_ip]
    }

    cluster = {
      apiServer = {
        certSANs = [var.lb_public_ip]
      }

      network = {
        podSubnets     = var.pod_subnets,
        serviceSubnets = var.service_subnets
      }
    }
  })
}

###############################################################################

############################# TALOS SECRETS & VAULT ###########################

resource "talos_machine_secrets" "cluster" {
  talos_version = var.talos_version
}

data "talos_client_configuration" "cluster" {
  cluster_name         = "${var.project_name}-${var.env}"
  client_configuration = talos_machine_secrets.cluster.client_configuration
  endpoints            = [var.lb_public_ip]
}

resource "vault_kv_secret_v2" "talos_secrets" {
  mount = "kvv2"
  name  = "${var.project_name}/${var.env}/talos/cluster-secrets"

  data_json = jsonencode({
    cluster_name     = "${var.project_name}-${var.env}"
    cluster_endpoint = "https://${var.lb_public_ip}:6443"
    machine_secrets  = talos_machine_secrets.cluster.machine_secrets
    client_config    = data.talos_client_configuration.cluster.talos_config
  })
}

###############################################################################

############################ MACHINE CONFIGURATIONS ###########################

data "talos_machine_configuration" "controlplane" {
  cluster_name     = "${var.project_name}-${var.env}"
  cluster_endpoint = "https://${var.lb_public_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets

  config_patches = concat(local.static_patches, [local.scheduling_patch], [local.dynamic_network_patch])
}

data "talos_machine_configuration" "worker" {
  cluster_name     = "${var.project_name}-${var.env}"
  cluster_endpoint = "https://${var.lb_public_ip}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets

  config_patches = local.static_patches
}

###############################################################################
