resource "openstack_compute_instance_v2" "worker" {
  depends_on = ["openstack_compute_instance_v2.master"]

  lifecycle = {
    create_before_destroy = true
  }

  count       = "${var.worker_count}"
  user_data   = "${data.template_cloudinit_config.server.rendered}"
  name        = "${var.worker_basename}${count.index}"
  image_name  = "${var.worker_image}"
  flavor_name = "${var.worker_flavor}"
  key_pair    = "${var.ssh_key_name}"

  stop_before_destroy = true

  network {
    uuid = "${openstack_networking_network_v2.kubeadm_net.id}"
  }

  security_groups = "${var.worker_sec_groups}"

  connection {
    # since these only have private addresses we connect through master
    bastion_host = "${openstack_networking_floatingip_v2.master_ip.address}"
  }

  provisioner "file" {
    source      = "wait-for-cloudinit.sh"
    destination = "/tmp/wait-for-cloudinit.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/sh /tmp/wait-for-cloudinit.sh"]
  }

  provisioner "file" {
    content     = "${data.template_file.cloud_conf.rendered}"
    destination = "/etc/kubernetes/cloud.conf"
  }

  provisioner "file" {
    source      = "files/kubelet.service.d.10-kubeadm.conf"
    destination = "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart kubelet",
    ]
  }

  # this is generated on master and copied back here
  # see master.tf (token in script only good within 24hr of creation on master)
  provisioner "remote-exec" {
    script = "./join.sh"
  }
}

output "worker private ips" {
  value = "${join(" ",openstack_compute_instance_v2.worker.*.network.0.fixed_ip_v4)}"
}
