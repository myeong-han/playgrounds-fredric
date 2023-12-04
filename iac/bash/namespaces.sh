#!/bin/bash

cd /home/mhkim/playgrounds-fredric/iac/helm
export nss=$(ls -al | grep -Evw "README.md" | sed '1,3d' | awk '{print $9}' | sed -z 's/[\n\r]/ /g')

for ns in $nss 
do
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: ${ns}
spec: {}
status: {}
---
EOF
done

kubectl label ns api-gateway istio-injection=enabled
