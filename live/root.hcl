################################# LOCAL VARIABLES ##############################
# Dynamically load environment configurations based on execution directory.

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  project_name  = local.env_vars.locals.project_name
  env           = local.env_vars.locals.env
  talos_version = local.common_vars.locals.talos_version
}

################################################################################

############################### LOCKFILE HANDLING ##############################
# Copy the terraform provider lockfile back to the configuration directory.
# This ensures provider dependency lockfiles are tracked in git for reproducibility.
terraform {
  copy_terraform_lock_file = true
}

################################################################################

################################# REMOTE STATE #################################
# Partition the state storage by environment and component directory to reduce blast radius.

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "3-istor-tf-infra-aws"
    key            = "openstack/projects/dockair/${local.env}/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

################################################################################

################################ PROVIDERS GENERATOR ###########################
# Standardize provider versions and address pools across all child directories.

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.11.0"
    }
  }
}

provider "openstack" {
}

provider "vault" {
  address = "https://vault.3istor.com/"
}
EOF
}

################################################################################
