################################# PARENT INCLUDES ##############################

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_env/compute.hcl"
}

################################################################################

#################################### INPUTS ####################################

inputs = {
  cp_count      = 1
  cp_flavor     = "m1.medium"
  worker_count  = 3
  worker_flavor = "m1.small"
}

################################################################################

