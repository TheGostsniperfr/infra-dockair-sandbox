locals {
  project_name    = "dockair-sandbox"
  env             = "staging"
  internal_cidr   = "10.20.1.0/24"
  pod_subnets     = ["10.20.8.0/21"]
  service_subnets = ["10.20.16.0/21"]
}
