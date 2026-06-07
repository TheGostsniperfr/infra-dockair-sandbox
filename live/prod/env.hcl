locals {
  project_name = "dockair-sandbox"
  env          = "prod"

  internal_cidr   = "10.10.1.0/24"
  pod_subnets     = ["10.10.8.0/21"]
  service_subnets = ["10.10.16.0/21"]
}
