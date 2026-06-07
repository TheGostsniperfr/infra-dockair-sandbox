################################# PARENT INCLUDES ##############################

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_env/network.hcl"
}

################################################################################
