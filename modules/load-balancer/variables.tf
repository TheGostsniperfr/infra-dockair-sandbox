variable "project_name" {
  description = "The name of the project to which the network belongs."
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "The project_name variable must not be empty."
  }
}

variable "subnet_id" {
  type        = string
  description = "The ID of the OpenStack internal subnet where the VIP will be allocated"

  validation {
    condition     = length(var.subnet_id) > 0
    error_message = "The subnet_id variable must not be empty."
  }
}

variable "control_plane_ips" {
  type        = list(string)
  description = "List of private IP addresses of the Talos Control Plane nodes (Masters)"

  validation {
    condition     = length(var.control_plane_ips) > 0
    error_message = "The control_plane_ips list must contain at least one IP address."
  }
}

variable "fip_address" {
  type        = string
  description = "The public Floating IP address allocated by the network module"

  validation {
    # Checks that the string matches the standard IPv4 address format (e.g. four octets of 1-3 digits separated by periods).
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.fip_address))
    error_message = "The fip_address variable must be a valid IPv4 address."
  }
}
