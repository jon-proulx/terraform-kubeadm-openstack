# this is the conf file for kubernetes to talk to openstack...
data "template_file" "cloud_conf" {
  template = "${file("files/cloud.conf.tmpl")}"

  vars {
    subnet_id = "${openstack_networking_subnet_v2.kubeadm_subnet.id}"

    # You need to pre-create a Keystone user in your OpenStack cloud
    # for kubernetes to use for interacting with OpenStack resources
    # login details fo rthat user go here
    user = "${var.cloud_connector_username}"

    password     = "${var.cloud_connector_userpass}"
    tenant_id    = "${var.cloud_connector_project_id}"
    domain_id    = "${var.cloud_connector_domain_id}"
    auth_url     = "${var.cloud_connector_auth_url}"
    external_net = "${var.external_net_id}"
  }
}

# kubeapi server needs to know keystone url too
data "template_file" "kube-apiserver_yaml" {
  template = "${file("files/kube-apiserver.yaml.tmpl")}"

  vars {
    auth_url = "${var.cloud_connector_auth_url}"
  }
}

data "template_cloudinit_config" "server" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"

    content = <<EOF
#!/bin/bash

#wait for dpkg lock
until dpkg --force-confold --configure -a; do sleep 10;done

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<STOPDOC >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
STOPDOC
#wait for dpkg lock
until dpkg --force-confold --configure -a; do sleep 10;done
apt-get update
#wait for dpkg lock
until dpkg --force-confold --configure -a; do sleep 10;done
apt-get install -y jq ebtables ethtool docker.io kubelet kubeadm kubectl
sysctl -w net.bridge.bridge-nf-call-iptables=1
echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.conf
touch /tmp/cloudinit.complete
EOF
  }

  # we rely a bit on ssh as root to make this go for now ...
  part {
    content_type = "text/cloud-config"

    content = <<EOF
#cloud-config
disable_root: false
manage_etc_hosts: true
EOF
  }
}
