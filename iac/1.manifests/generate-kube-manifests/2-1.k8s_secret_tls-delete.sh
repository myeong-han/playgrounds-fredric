#!/bin/bash
secret=$1
nss=$(kubectl get ns --no-headers | awk '{print $1}' | grep -Ev 'kube-system|kube-public|kube-node-lease' | sed -z 's/[\n\r]/ /g')

#k8s secret 삭제
for ns in $nss
do
	kubectl delete secret -n $ns $secret
done
