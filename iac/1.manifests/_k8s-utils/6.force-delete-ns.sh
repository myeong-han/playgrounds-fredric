#!/bin/bash

if [ -z $1 ]; then
	echo "##Report: Namespace를 첫번째 파라미터로 입력해야 동작합니다."
	exit 1
fi

ns=$1
kubeproxy=$(netstat -lntp | grep '127.0.0.1:8001')
if [ -z $kubeproxy ]; then
	kubectl proxy &
fi

#yaml 파일로 적용할 temp.json 파일 생성
kubectl get namespace $ns -o json |jq '.spec = {"finalizers":[]}' > temp.json

#수정사항 반영
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json http://127.0.0.1:8001/api/v1/namespaces/$ns/finalize
