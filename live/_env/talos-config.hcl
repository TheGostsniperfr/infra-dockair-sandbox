############################### TERRAFORM SOURCE ###############################

terraform {
  source = "${get_repo_root()}/modules//talos-config"
}

################################################################################

################################# LOCAL VARIABLES ##############################

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
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

################################################################################

#################################### INPUTS ####################################

inputs = {
  project_name    = local.env_vars.locals.project_name
  env             = local.env_vars.locals.env
  talos_version   = local.common_vars.locals.talos_version
  pod_subnets     = local.env_vars.locals.pod_subnets
  service_subnets = local.env_vars.locals.service_subnets
  lb_public_ip    = dependency.network.outputs.fip_address
}

################################################################################
