output "cp_ips" {
  description = "The fixed IPv4 addresses of the control plane instances."
  value       = openstack_networking_port_v2.cp_port[*].all_fixed_ips[0]
}
