#!/bin/bash
ssl_home=/etc/ssl/fredric
nss=$(kubectl get ns --no-headers | awk '{print $1}' | grep -Ev 'kube-system|kube-public|kube-node-lease' | sed -z 's/[\n\r]/ /g')
secret=fredric.playground.cld-tls

#k8s secret 생성
for ns in $nss
do
	kubectl create secret -n $ns tls $secret \
	  --cert="$ssl_home/server.pem" \
	  --key="$ssl_home/server.key"
done
