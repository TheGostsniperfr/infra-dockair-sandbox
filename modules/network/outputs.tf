output "subnet_id" {
  description = "The ID of the internal subnet."
  value       = openstack_networking_subnet_v2.internal_subnet.id
}

output "internal_net_id" {
  description = "The ID of the internal network."
  value       = openstack_networking_network_v2.internal_net.id
}

output "fip_address" {
  description = "The allocated floating IP address."
  value       = openstack_networking_floatingip_v2.api_fip.address
}
