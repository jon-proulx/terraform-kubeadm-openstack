#!/bin/sh

# it would be great if this had any error checking

CERT_HASH=sha256:$( openssl rsa -in /etc/kubernetes/pki/ca.key -pubout -outform der |sha256sum | sed 's/-//;' )
TOKEN=$( kubeadm token list |awk -e '/default/{print $1}' )
PRIVATE_IP=$( curl http://169.254.169.254/latest/meta-data/local-ipv4 )

JOIN_COMMAND="kubeadm join --token $TOKEN ${PRIVATE_IP}:443 --discovery-token-ca-cert-hash $CERT_HASH"

cat <<EOF > /tmp/join.sh
#!/bin/sh
$JOIN_COMMAND
EOF
