#!/bin/bash

target_domain=$1
hostfile=/etc/hosts
hostnames=($(cat ../_env/hosts.txt))

#validation1
if [ -z $1 ]; then
	echo "##Report: 도메인정보를 첫번째 파라미터로 입력해야 동작합니다."
	echo "##Sample: # sudo bash ./update_etc_hosts-macos.sh [target_domain]"
	exit 1
fi

#validation2
if [ $USER != 'root' ]; then
	echo "##Report: sudo 권한으로 다시 실행하십시오..."
	echo "##Sample: # sudo bash ./update_etc_hosts-macos.sh [target_domain]"
	exit 1
fi

#validation3
if [ -z $hostnames ]; then
        echo "##Report: $(pwd)/../_env/hosts.txt 파일을 찾을 수 없습니다. 실행위치 혹은 파일위치를 확인하세요."
        exit 1
fi

target_ip=$(nslookup $target_domain | grep "Address:" | awk '{ print $2 }' | sed '1d' | head -n 1 | tr '\n' '\t')

#validation4
if [ -z $target_ip ]; then
	echo "##Report: target ip를 정상적으로 가져오지 못했으므로 종료합니다."
	exit 1
fi

#find & delete
for hostname in "${hostnames[@]}"; do
	del_line=$( cat /etc/hosts | grep $hostname | head -n 1 )
	echo "Delete Line: $del_line"
	sed -i '' -e "/$del_line/d" "$hostfile"
#	cat /etc/hosts | grep -v ${hostname}
done

#insert
for hostname in "${hostnames[@]}"; do
	echo "Add Line: ${target_ip}${hostname}"
	echo "${target_ip}${hostname}" >> $hostfile
done
