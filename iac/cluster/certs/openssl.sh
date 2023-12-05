#!/bin/bash

cd /etc/ssl/fredric

#개인키 생성
openssl genrsa -aes256 -out private.key 2048
openssl rsa -in private.key -pubout -out public.key
openssl req -new -key private.key -out private.csr

#CA key 생성
openssl genrsa -aes256 -out root.ca.key 2048
#CA 10년 서명요청
openssl req -x509 -new -nodes -key root.ca.key -days 3650 -out root.ca.pem
#CA 10년 인증서 생성
openssl x509 -req -in private.csr -CA root.ca.pem -CAkey root.ca.key -CAcreateserial -out private.crt -days 3650
