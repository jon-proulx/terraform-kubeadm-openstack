### You need to pre-create a Keystone user in your OpenStack cloud
### for kubernetes to use for interacting with OpenStack resources
### login details for that user go here

### in reality they should not go here but in a file outside vcs
### or be specified on terraform command line, but for exposition...

cloud_connector_username = "REPLACE"
cloud_connector_userpass = "REPLACE"
cloud_connector_project_id = "REPLACE"
cloud_connector_auth_url = "https://REPLACE:5000/v3"
#cloud_connector_domain_id = "default"
### Common config
ssh_key_name = "REPLACE"

### Private Network details
## you will need to change these
# id of external network, this is where your virtual router will connect
# and where VIPs for LBaaS will come from
external_net_id = "REPLACE"
# These are https://www.opennic.org/ and will work, but you probably
# want local values here
dns_nameservers = ["128.52.130.209", "172.98.193.42", "192.99.85.244"]
## these can probably stay as is 
private_net_name = "kube2_net"
private_subnet_name = "kube2_subnet"
private_router_name = "kube2_router"
#private_cidr = "10.142.0.0/16"
#private_allocation_start = "10.142.0.100"
#private_allocation_end = "10.142.255.200" 

### Master node details
master_name = "kubemaster"
# enter comma seperated list of alternate cert names here if needed
# extra_api_cert_names = "kubeapi.example.com,kubeapi"
extra_api_cert_names = ""
master_image = "REPLACE"
master_flavor = "REPLACE"
# since this is implemented as a "port" these must be IDs not names sadly.
# need to use "port" rather than "instance" config so we can get floating IP setup
# in time to use it with remote exec provisioner you will need ssh
# from management station and open interanal connection
# master_sec_group_ids = [ "0fd7ea85-32f4-4e1d-974d-edb3fba8fc37","2d2a123c-dd52-48a4-99fa-98a5011988f6" ]
master_sec_group_ids = []

# floating IP pool name from which to pull master's public IP
master_float_pool_name = "REPLACE"

### Worker node details
worker_count = 3
worker_basename = "kube-worker"
worker_image = "REPLACE"
worker_flavor = "REPLACE"
# worker sec groups are set in "instance" so names are ok
# need open conenction to master if both are in "default" secugroup
# (and you've left it as it comes by default) this is all you need
worker_sec_groups = ["default"]
