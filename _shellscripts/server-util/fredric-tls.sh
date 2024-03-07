#!/bin/bash

#validation1
if [ -z $1 ]; then
	echo "##Report: key 알고리즘(ecparam, rsa)를 첫번째 파라미터로 입력해야 동작합니다."
	exit 1
fi

#validation
if [ $USER != 'root' ]; then
        echo "##Report: sudo 권한으로 다시 실행하십시오..."
        exit 1
fi
ssl_home=/etc/ssl/fredric/v2
days=365
algorithm=$1
confighome=/home/mhkim/playgrounds-fredric/_shellscripts/_env

rm -rf $ssl_home
mkdir $ssl_home
cd $ssl_home

#루트인증서
if [ "$algorithm" == "ecparam" ]; then
	openssl ecparam -out rootca.key -name prime256v1 -genkey
	openssl req -new -sha256 -key rootca.key -out rootca.csr -subj "/C=KR/L=Seoul/O=fredric/CN=fredrics.playground"
	openssl x509 -req -sha256 -days 3650 -in rootca.csr -signkey rootca.key -out rootca.crt
elif [ "$algorithm" == "rsa" ]; then
	openssl genpkey -algorithm RSA -out rootca.key -pkeyopt rsa_keygen_bits:2048
	openssl req -new -sha256 -key rootca.key -out rootca.csr -subj "/C=KR/L=Seoul/O=fredric/CN=fredrics.playground"
	openssl x509 -req -sha256 -days 3650 -in rootca.csr -signkey rootca.key -out rootca.crt -extensions v3_ca -extfile $confighome/openssl-ext.cnf
fi

#서버인증서
if [ "$algorithm" == "ecparam" ]; then
	openssl ecparam -out server.key -name prime256v1 -genkey
elif [ "$algorithm" == "rsa" ]; then
	openssl genpkey -algorithm RSA -out server.key -pkeyopt rsa_keygen_bits:2048
fi
openssl req -new -sha256 -key server.key -out server.csr -subj "/C=KR/L=Seoul/O=fredric/CN=*.fredric.playground.cld" -addext "subjectAltName = DNS:harbor.fredric.playground.cld,IP:192.168.0.4,IP:192.168.0.6"
openssl x509 -req -sha256 -days 3650 -in server.csr -CA rootca.crt -CAkey rootca.key -CAcreateserial -out server.crt

#서버인증서 정보 출력
openssl x509 -in server.crt -text -noout

#루트인증서와 서버인증서를 모두 포함하는 pem파일 제작
cat server.crt rootca.crt > server.pem
