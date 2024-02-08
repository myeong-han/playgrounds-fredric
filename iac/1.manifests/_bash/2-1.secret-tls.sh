#!/bin/bash
export certhome=/home/mhkim/fredric-certs
export key=$(base64 -w 0 ${certhome}/private.key)
export crt=$(base64 -w 0 ${certhome}/private.crt)

export ns=forward
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kong-proxy-tls
  namespace: ${ns}
type: kubernetes.io/tls
data:
  tls.key: ${key}
  tls.crt: ${crt}
EOF
