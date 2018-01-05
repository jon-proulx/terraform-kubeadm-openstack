resource "openstack_compute_instance_v2" "master" {
  user_data   = "${data.template_cloudinit_config.server.rendered}"
  name        = "${var.master_name}"
  image_name  = "${var.master_image}"
  flavor_name = "${var.master_flavor}"
  key_pair    = "${var.ssh_key_name}"

  stop_before_destroy = true

  lifecycle = {
    create_before_destroy = false
  }

  network {
    port = "${openstack_networking_port_v2.master.id}"
  }

  connection {
    host = "${openstack_networking_floatingip_v2.master_ip.address}"
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

  # there seems to be a race where sometimes the later call to
  # "gen-join.sh" returns an empty token even though later calls get
  # it so sleep 30s at the end here 
  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart kubelet",
      "kubeadm init --apiserver-advertise-address  ${openstack_networking_floatingip_v2.master_ip.address} --apiserver-bind-port 443 --apiserver-cert-extra-sans ${self.network.0.fixed_ip_v4},${var.extra_api_cert_names} --pod-network-cidr=10.244.0.0/16",
      "kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.0/Documentation/kube-flannel.yml",
      "sleep 30",
    ]
  }

  # note kubeadmin preflight fails if this file exists before the
  # 'kubeadm init' run, API server *should* restart itself when this
  # updates I think...
  provisioner "file" {
    content     = "${data.template_file.kube-apiserver_yaml.rendered}"
    destination = "/etc/kubernetes/manifests/kube-apiserver.yaml"
  }

  # joining command depends on thing best seen from master
  # so generate it there then copy back
  #
  # note joining tokens expire after 24hr so need to manually create one if
  # expanding cluster later see 'kubeadm token create -help' on master node
  provisioner "remote-exec" {
    script = "./gen-join.sh"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no root@${openstack_networking_floatingip_v2.master_ip.address}:/tmp/join.sh ."
  }

  # grab admin.conf while we're here ...
  provisioner "local-exec" {
    command = "scp root@${openstack_networking_floatingip_v2.master_ip.address}:/etc/kubernetes/admin.conf  ."
  }
}

output "master public ip" {
  value = "${openstack_networking_floatingip_v2.master_ip.address}"
}

output "master private ip" {
  value = "${openstack_compute_instance_v2.master.network.0.fixed_ip_v4}"
}
