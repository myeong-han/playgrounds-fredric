#!/bin/bash
ssl_home=/etc/ssl/fredric
days=365

#validation
if [ $USER != 'root' ]; then
        echo "##Report: sudo 권한으로 다시 실행하십시오..."
        exit 1
fi

rm -rf $ssl_home
mkdir $ssl_home
cd $ssl_home

#루트인증서
openssl ecparam -out rootca.key -name prime256v1 -genkey
openssl req -new -sha256 -key rootca.key -out rootca.csr -subj "/C=KR/L=Seoul/O=fredric/CN=fredrics.playground"
openssl x509 -req -sha256 -days 3650 -in rootca.csr -signkey rootca.key -out rootca.crt

#서버인증서
openssl ecparam -out server.key -name prime256v1 -genkey
openssl req -new -sha256 -key server.key -out server.csr -subj "/C=KR/L=Seoul/O=fredric/CN=*.fredric.playground.cld"
openssl x509 -req -sha256 -days 3650 -in server.csr -CA rootca.crt -CAkey rootca.key -CAcreateserial -out server.crt

#서버인증서 정보 출력
openssl x509 -in server.crt -text -noout

#루트인증서와 서버인증서를 모두 포함하는 pem파일 제작
cat server.crt rootca.crt > server.pem
