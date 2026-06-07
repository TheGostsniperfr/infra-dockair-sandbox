############################### TERRAFORM SOURCE ###############################

terraform {
  source = "${get_repo_root()}/modules//load-balancer"
}

################################################################################

################################# LOCAL VARIABLES ##############################

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

################################################################################

################################# DEPENDENCIES #################################
# Inject mock values during plan/validate to bypass missing state on bootstrapping.

dependency "network" {
  config_path                             = "${get_terragrunt_dir()}/../network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    subnet_id   = "mock-subnet-id"
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

################################################################################

#################################### INPUTS ####################################

inputs = {
  project_name      = local.env_vars.locals.project_name
  env               = local.env_vars.locals.env
  subnet_id         = dependency.network.outputs.subnet_id
  fip_address       = dependency.network.outputs.fip_address
  control_plane_ips = dependency.compute.outputs.cp_ips
}

################################################################################
