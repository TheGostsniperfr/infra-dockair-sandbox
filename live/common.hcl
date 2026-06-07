############################### GLOBAL CONFIGURATION ###########################
# Maintain version and static resource consistency across all deployable environments.

locals {
  talos_version = "v1.13.3"
  image_name    = "talos-v1.13.3"
  keypair_name  = "3-istor-cloud-kp-admin"
  dns_servers   = ["1.1.1.1", "8.8.8.8"]
}


################################################################################
