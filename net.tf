# Private network
#
#
resource "openstack_networking_network_v2" "kubeadm_net" {
  name           = "${var.private_net_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "kubeadm_subnet" {
  name       = "$(var.private_subnet_name}"
  network_id = "${openstack_networking_network_v2.kubeadm_net.id}"
  cidr       = "${var.private_cidr}"

  allocation_pools {
    start = "${var.private_allocation_start}"
    end   = "${var.private_allocation_end}"
  }

  dns_nameservers = "${var.dns_nameservers}"
  ip_version      = 4
  enable_dhcp     = true
}

resource "openstack_networking_router_v2" "kubeadm_router" {
  name             = "${var.private_router_name}"
  external_gateway = "${var.external_net_id}"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.kubeadm_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.kubeadm_subnet.id}"
}
