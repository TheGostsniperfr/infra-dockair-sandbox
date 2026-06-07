############################### TALOS BOOTSTRAP ###############################

resource "talos_machine_bootstrap" "bootstrap" {
  node                 = var.bootstrap_node_ip
  endpoint             = var.lb_public_ip
  client_configuration = var.client_configuration
}

###############################################################################
