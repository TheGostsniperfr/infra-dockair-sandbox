variable "project_name" {
  description = "The name of the project to which the network belongs."
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "The project_name variable must not be empty."
  }
}

variable "dns_servers" {
  description = "A list of DNS servers to use for the subnet."
  type        = list(string)
}

variable "internal_cidr" {
  description = "The CIDR for the internal network"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.internal_cidr))
    error_message = "The internal_cidr variable must be a valid IPv4 CIDR range."
  }
}

variable "floating_ip_pool" {
  description = "The name of the external network pool used to allocate the public Floating IP"
  type        = string
}

variable "env" {
  description = "The target deployment environment (e.g. staging, prod)."
  type        = string

  validation {
    condition     = contains(["staging", "prod"], var.env)
    error_message = "The env variable must be either 'staging' or 'prod'."
  }
}
