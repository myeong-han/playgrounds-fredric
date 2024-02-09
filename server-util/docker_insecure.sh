#!/bin/sh

#validation1
if [ -z $1 ]; then
	echo "##Report: 도메인정보를 첫번째 파라미터로 입력해야 동작합니다."
	exit 1
fi

#validation2
if [ $USER != 'root' ]; then
	echo "##Report: sudo 권한으로 다시 실행하십시오..."
	exit 1
fi

bash -c "cat << EOF > /etc/docker/daemon.json
{
        \"insecure-registries\": [\"$1\"]
}
"
systemctl restart docker
docker info
