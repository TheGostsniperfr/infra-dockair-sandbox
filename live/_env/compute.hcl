############################### TERRAFORM SOURCE ###############################

terraform {
  source = "${get_repo_root()}/modules//compute"
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
    internal_net_id = "mock-net-id"
    secgroup_ids    = ["mock-sg-base-id", "mock-sg-talos-id", "mock-sg-k3s-id"]
  }
}

dependency "talos_config" {
  config_path                             = "${get_terragrunt_dir()}/../talos-config"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    cp_user_data     = "mock-user-data"
    worker_user_data = "mock-user-data"
  }
}

################################################################################

#################################### INPUTS ####################################

inputs = {
  project_name     = local.env_vars.locals.project_name
  env              = local.env_vars.locals.env
  image_name       = local.common_vars.locals.image_name
  keypair_name     = local.common_vars.locals.keypair_name
  internal_net_id  = dependency.network.outputs.internal_net_id
  secgroup_ids     = dependency.network.outputs.secgroup_ids
  cp_user_data     = dependency.talos_config.outputs.cp_user_data
  worker_user_data = dependency.talos_config.outputs.worker_user_data
}

################################################################################
