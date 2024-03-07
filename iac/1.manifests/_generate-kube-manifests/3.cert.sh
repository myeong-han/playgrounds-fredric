#!/bin/bash
# Copyright March 7, 2024 Myeong-han Kim.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

echo "##Report: 세번째 파라미터를 입력할 경우 해당 도메인에 대한 인증서 발급, 입력하지 않을 경우 env에 등록된 모든 도메인에 대한 인증서 발급."
echo "#############################################"
echo "###exec> bash $0 $1 $2 $3 | kubectl apply -f -"
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

if [ -z $3 ]; then
	# DNS 도메인들을 반복하여 추가
	for domain in "${DOMAINS[@]}"; do
		echo "  - $domain"
	done
else
	echo "  - $3"
fi
# 마지막 부분에 다시 EOF를 붙여서 종료
echo "---"
