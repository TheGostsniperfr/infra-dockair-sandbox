############################### TERRAFORM SOURCE ###############################

terraform {
  source = "${get_repo_root()}/modules//cluster-bootstrap"
}

################################################################################

################################# DEPENDENCIES #################################
# Inject mock values during plan/validate to bypass missing state on bootstrapping.

dependency "network" {
  config_path                             = "${get_terragrunt_dir()}/../network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    fip_address = "192.0.2.1"
  }
}

dependency "compute" {
  config_path                             = "${get_terragrunt_dir()}/../compute"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    cp_ips = ["192.0.2.10"]
  }
}

dependency "talos_config" {
  config_path                             = "${get_terragrunt_dir()}/../talos-config"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    client_configuration = {}
  }
}

################################################################################

#################################### INPUTS ####################################

inputs = {
  bootstrap_node_ip    = dependency.compute.outputs.cp_ips[0]
  lb_public_ip         = dependency.network.outputs.fip_address
  client_configuration = dependency.talos_config.outputs.client_configuration
}

################################################################################
