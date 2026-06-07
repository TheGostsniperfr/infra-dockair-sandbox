############################### TERRAFORM SOURCE ###############################

terraform {
  source = "${get_repo_root()}/modules//network"
}

################################################################################

################################# LOCAL VARIABLES ##############################

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  dns_servers = try(local.env_vars.locals.dns_servers, local.common_vars.locals.dns_servers)
}

################################################################################

#################################### INPUTS ####################################

inputs = {
  project_name     = local.env_vars.locals.project_name
  env              = local.env_vars.locals.env
  internal_cidr    = local.env_vars.locals.internal_cidr
  dns_servers      = local.dns_servers
  floating_ip_pool = "ext-net"
}

################################################################################
