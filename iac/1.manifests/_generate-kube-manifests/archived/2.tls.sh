cert=/etc/ssl/fredric/server.crt
key=/etc/ssl/fredric/server.key
cacert=/etc/ssl/fredric/rootca.crt

#validation1
if [ -z $1 ]; then
	echo "##Report: 첫번째 파라미터 입력으로 namespace를 설정하세요."
	exit 1
fi

#validation1
if [ -z $2 ]; then
        echo "##Report: 두번째 파라미터 입력으로 도메인을 완성하세요"
        echo "##Example: # ?.fredric.plaground.cld-tls"
        exit 1
fi

#validation2
if [ $USER != 'root' ]; then
        echo "##Report: sudo 권한으로 다시 실행하십시오..."
        exit 1
fi

kubectl delete secret -n $1 $2.fredric.playground.cld-tls
#kubectl create secret tls -n cicd harbor.fredric.playground.cld-tls --cert=$cert --key=$key
kubectl create secret generic -n $1 $2.fredric.playground.cld-tls --from-file=ca.crt=$cacert --from-file=tls.crt=$cert --from-file=tls.key=$key
