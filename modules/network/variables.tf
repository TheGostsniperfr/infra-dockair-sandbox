variable "project_name" {
  description = "The name of the project to which the network belongs."
  type        = string
}

variable "dns_servers" {
  description = "A list of DNS servers to use for the subnet."
  type        = list(string)
}

variable "internal_cidr" {
  description = "The CIDR for the internal network"
  type        = string
}

variable "floating_ip_pool" {
  description = "The name of the external network pool used to allocate the public Floating IP"
  type        = string
}
