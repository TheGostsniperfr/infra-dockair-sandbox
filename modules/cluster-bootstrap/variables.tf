variable "bootstrap_node_ip" {
  description = "The private IPv4 address of the first control plane node to trigger etcd bootstrap"
  type        = string

  validation {
    # Checks that the string matches the standard IPv4 address format (e.g. four octets of 1-3 digits separated by periods).
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.bootstrap_node_ip))
    error_message = "The bootstrap_node_ip variable must be a valid IPv4 address."
  }
}

variable "lb_public_ip" {
  description = "The public endpoint (FIP) of the Load Balancer"
  type        = string

  validation {
    # Checks that the string matches the standard IPv4 address format (e.g. four octets of 1-3 digits separated by periods).
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.lb_public_ip))
    error_message = "The lb_public_ip variable must be a valid IPv4 address."
  }
}

variable "client_configuration" {
  description = "The Talos client configuration secrets retrieved from talos-config"
  type        = map(any)
  sensitive   = true

  validation {
    condition     = length(var.client_configuration) > 0
    error_message = "The client_configuration map must not be empty."
  }
}
