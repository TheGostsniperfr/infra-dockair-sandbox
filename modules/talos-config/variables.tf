variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "talos_version" {
  type = string
}

variable "lb_public_ip" {
  type = string
}

variable "pod_subnets" {
  type = list(string)
}

variable "service_subnets" {
  type = list(string)
}

variable "worker_count" {
  type = number
}
