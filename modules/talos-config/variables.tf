variable "project_name" {
  type = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "The project_name variable must not be empty."
  }
}

variable "env" {
  type = string

  validation {
    condition     = contains(["staging", "prod"], var.env)
    error_message = "The env variable must be either 'staging' or 'prod'."
  }
}

variable "talos_version" {
  type = string

  validation {
    condition     = length(var.talos_version) > 0
    error_message = "The talos_version variable must not be empty."
  }
}

variable "lb_public_ip" {
  type = string

  validation {
    # Checks that the string matches the standard IPv4 address format (e.g. four octets of 1-3 digits separated by periods).
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.lb_public_ip))
    error_message = "The lb_public_ip variable must be a valid IPv4 address."
  }
}

variable "pod_subnets" {
  type = list(string)

  validation {
    condition     = length(var.pod_subnets) > 0
    error_message = "The pod_subnets list must contain at least one CIDR block."
  }
}

variable "service_subnets" {
  type = list(string)

  validation {
    condition     = length(var.service_subnets) > 0
    error_message = "The service_subnets list must contain at least one CIDR block."
  }
}

variable "worker_count" {
  type = number

  validation {
    condition     = var.worker_count >= 1
    error_message = "The worker_count variable must be a positive integer."
  }
}
