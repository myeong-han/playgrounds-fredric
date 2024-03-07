#!/bin/bash

#validation1
if [ -z $1 ]; then
	echo "##Report: Certificate Name(Secret Name)을 첫번째 파라미터로 입력해야 동작합니다."
		        exit 1
fi
#validation1
if [ -z $2 ]; then
	        echo "##Report: Namespace명을 두번째 파라미터로 입력해야 동작합니다."
		        exit 1
fi

echo "#############################################"
echo "###Create> bash $0 $1 $2 | kubectl apply -f -"
echo "#############################################"

# Certificate의 이름과 네임스페이스를 변수로 지정
CERT_NAME=$1
NAMESPACE=$2
# 도메인 이름들을 배열로 입력 받음. 예를 들어, "domain1.com domain2.com"
DOMAINS=($(cat /home/mhkim/playgrounds-fredric/_shellscripts/_env/hosts.txt))

# Certificate 정의 시작
cat <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: $CERT_NAME
  namespace: $NAMESPACE
spec:
  secretName: $CERT_NAME #생성될 secret Name
  issuerRef:
    name: ca-issuer
    kind: ClusterIssuer
  dnsNames:
EOF

# DNS 도메인들을 반복하여 추가
for domain in "${DOMAINS[@]}"; do
	echo "  - $domain"
done
# 마지막 부분에 다시 EOF를 붙여서 종료
echo "---"
