variable "bootstrap_node_ip" {
  description = "The private IPv4 address of the first control plane node to trigger etcd bootstrap"
  type        = string
}

variable "lb_public_ip" {
  description = "The public endpoint (FIP) of the Load Balancer"
  type        = string
}

variable "client_configuration" {
  description = "The Talos client configuration secrets retrieved from talos-config"
  type        = map(any)
  sensitive   = true
}
