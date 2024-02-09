#!/bin/bash
ssl_home=/etc/ssl/fredric
nss=$(kubectl get ns --no-headers | awk '{print $1}' | grep -Ev 'kube-system|kube-public|kube-node-lease' | sed -z 's/[\n\r]/ /g')
secret=fredric.playground.cld-tls

#validation
if [ $USER != 'root' ]; then
        echo "##Report: sudo 권한으로 다시 실행하십시오..."
        exit 1
fi

rm -rf $ssl_home
mkdir $ssl_home
cd $ssl_home

#자체서명 인증서 생성
openssl req -x509 \
  -newkey rsa:2048 \
  -keyout fredric.key \
  -out fredric.crt \
  -days 365 \
  -nodes \
  -subj "/C=KO/L=Seoul/O=fredric/CN=*.fredric.playground.cld"

#k8s secret 생성
for ns in $nss
do
	kubectl create secret -n $ns tls $secret \
	  --cert="$ssl_home/fredric.crt" \
	  --key="$ssl_home/fredric.key"
done
