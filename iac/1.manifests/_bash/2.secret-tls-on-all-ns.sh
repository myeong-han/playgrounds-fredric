#!/bin/bash
export certhome=/home/mhkim/fredric-certs
export key=$(base64 -w 0 ${certhome}/private.key)
export crt=$(base64 -w 0 ${certhome}/private.crt)

export nss=$(kubectl get ns --no-headers | awk '{print $1}' | grep -Ev 'kube-system|kube-public|kube-node-lease' | sed -z 's/[\n\r]/ /g')

for ns in $nss
do
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: ${ns}
type: kubernetes.io/tls
data:
  tls.key: ${key}
  tls.crt: ${crt}
EOF
done
