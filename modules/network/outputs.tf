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

output "secgroup_ids" {
  description = "The IDs of the created security groups."
  value = [
    openstack_networking_secgroup_v2.sg_base.id,
    openstack_networking_secgroup_v2.sg_talos.id,
    openstack_networking_secgroup_v2.sg_k3s.id
  ]
}

