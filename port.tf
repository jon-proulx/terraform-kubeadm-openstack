resource "openstack_networking_floatingip_v2" "master_ip" {
  pool    = "${var.master_float_pool_name}"
  port_id = "${openstack_networking_port_v2.master.id}"
}

resource "openstack_networking_port_v2" "master" {
  name           = "kubeadm_master_port"
  admin_state_up = "true"

  # "private" network
  network_id = "${openstack_networking_network_v2.kubeadm_net.id}"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.kubeadm_subnet.id}"
  }

  security_group_ids = "${var.master_sec_group_ids}"
}
