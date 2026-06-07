variable "project_name" {
  description = "The name of the project to which the network belongs."
  type        = string
}

variable "subnet_id" {
  type        = string
  description = "The ID of the OpenStack internal subnet where the VIP will be allocated"
}

variable "control_plane_ips" {
  type        = list(string)
  description = "List of private IP addresses of the Talos Control Plane nodes (Masters)"
}

variable "fip_address" {
  type        = string
  description = "The public Floating IP address allocated by the network module"
}
