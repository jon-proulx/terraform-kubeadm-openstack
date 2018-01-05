Cluster Deploy Notes
=============

This is kina creaky!

EDIT terraform.tfvars to set site specific requirements

Only meant as PoC, the k8s cluster it creates is all ephemeral and the
control plane is not redundant so if you delete the master you should
delete the workers too. But don't  `terraform destroy` unless you mean
it keeping the network, port and floatingip stuff between iterations is
probably useful.

It works as a greenfield deployment but not so well with adding nodes
or other run time management.  You can do it but it takes some hand
holding that's probably not worth explaining for an early stage test.

Hard Coded Assumptions
==================

Pod networking uses Flanel and a pod cidr of 10.244.0.0/16 which is
also assumed by default Flanel config this is set in master.tf

Flanel version (v0.9.0) is also hard coded in remote-exec line in
master.tf

  "kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.0/Documentation/kube-flannel.yml "

This is only tested with Ubuntu 16.04 Xenial base images it might work
on other Debian variants but would definately need significant work to
make it go on other families of Linux.

Accessing Deployed Cluster
=================

admin.conf in this directory should be current version of credential
to run the cluster.  You can either use:

  kubectl --kubeconfig=admin.conf

or copy it to the default location ~/.kube/config

kubectl itself can be got from:

  root@kubeadm-master:~# cat /etc/apt/sources.list.d/kubernetes.list
  deb http://apt.kubernetes.io/ kubernetes-xenial main

or from links at:

  https://kubernetes.io/docs/tasks/tools/install-kubectl/

we're using 1.8.x on the server side though I don't think version
matching is critical.


What's here
=======

*  admin.conf - (generated file) credential for k8s cluster
*  data.tf - cloudinit bits for all nodes
*  files - directory of things pushed to nodes at build time
*  gen-join.sh - script run on master to generate join 
   command which is run on workers credential in this file is time limited 
   so only useful within 24h of terraform apply
*  join.sh - (generated file) output of gen-join.sh copied from master to run on workers
*  master.tf - config for master node
*  net.tf - setup private k8s net
*  port.tf - port and floatingip setup for master node (most wonkiness
   is here I think)
*  README.md - this file
*  terraform.tfvars - EDIT THIS FILE it contains the site specific
   bits
*  vars.tf - variable declarations and defaults
*  workers.tf - config for worker nodes
