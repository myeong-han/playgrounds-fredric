#!/bin/bash

target=/etc/rancher/k3s/registries.yaml
auth=$(echo "admin:$1" | tr -d '\n' | base64)

#validation1
if [ -z $1 ]; then
        echo "##Report: 로그인 패스워드 정보를 첫번째 파라미터로 입력해야 동작합니다."
        exit 1
fi

#validation2
if [ $USER != 'root' ]; then
        echo "##Report: sudo 권한으로 다시 실행하십시오..."
        exit 1
fi

bash -c "cat << EOF > $target
mirrors:
  \"harbor.fredric.playground.cld\":
    endpoint:
      - \"http://harbor.fredric.playground.cld\"
configs:
  \"harbor.fredric.playground.cld\":
    auth:
      auth: \"${auth}\"
    tls:
      insecure_skip_verify: true
EOF"

systemctl restart k3s
crictl info | jq -r '.config.registry'
