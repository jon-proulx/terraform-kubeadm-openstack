# fill in the blanks in terraform.tfvars 
variable "cloud_connector_username" {}

variable "cloud_connector_userpass" {}
variable "cloud_connector_project_id" {}
variable "cloud_connector_auth_url" {}

variable "cloud_connector_domain_id" {
  default = "default"
}

variable "ssh_key_name" {}
variable "external_net_id" {}

variable "dns_nameservers" {
  default = []
}

variable "private_net_name" {
  default = "kubeadm_net"
}

variable "private_subnet_name" {
  default = "kubeadm_subnet"
}

variable "private_router_name" {
  default = "kubeadm_router"
}

variable "private_cidr" {
  default = "10.142.0.0/16"
}

variable "private_allocation_start" {
  default = "10.142.0.100"
}

variable "private_allocation_end" {
  default = "10.142.255.200"
}

variable "master_name" {
  default = "kubemaster"
}

variable "extra_api_cert_names" {
  default = ""
}

variable "master_image" {
  default = "xenial-server-cloudimg-amd64"
}

variable "master_flavor" {}

variable "master_sec_group_ids" {
  default = []
}

variable "master_float_pool_name" {}

variable "worker_count" {
  default = 3
}

variable "worker_basename" {
  default = "kube-worker"
}

variable "worker_image" {
  default = "xenial-server-cloudimg-amd64"
}

variable "worker_flavor" {}

variable "worker_sec_groups" {
  default = ["default"]
}
