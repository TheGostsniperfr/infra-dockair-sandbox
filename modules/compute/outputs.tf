output "cp_ips" {
  description = "The fixed IPv4 addresses of the control plane instances."
  value       = openstack_compute_instance_v2.controlplane[*].network.0.fixed_ip_v4
}
