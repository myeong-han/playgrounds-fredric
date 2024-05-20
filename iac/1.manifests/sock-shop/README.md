# sockshop-istio
### ~사전 설정~
~1. istio-ingress svc의 Cluster-IP를 구한다 ex)`k get svc -n istio-system`~
~2. `vi util_fortio.yaml` 내에서 `.spec.template.spec.hostAliases[0].ip`의 값을 위의 값으로 수정한다.~

### 사전 설정
1. istio-ingress svc의 FQDN 확인 (이하 gateway.istio-ingress.svc로 설명)
2. `vi sock-shop/sock-shop/init/ingress-gateway.yaml` 에서 `spec.servers[0].hosts[0]` 수정

### configuering
```bash                                                                                                                        
#global
kubectl apply -f ns.yaml
kubectl apply -f util_fortio.yaml #in default namespace

#sock-shop ns application & dr
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/v1-deploy.yaml -f sock-shop/init/v2-deploy.yaml -f sock-shop/init/vs.yaml
```

### TEST
```bash
#test abort fault injection
k apply -n sock-shop -f sock-shop/abort-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://gateway.istio-ingress.svc/catalogue
# CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml

#test delay fault injection
k apply -n sock-shop -f sock-shop/delay-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://gateway.istio-ingress.svc/catalogue
# CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml

#test canary deploy
k apply -n sock-shop -f sock-shop/canary-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://gateway.istio-ingress.svc/index.html
# CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml

#test bluegreen deploy
## switch v2
k apply -n sock-shop -f sock-shop/v2-route-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://gateway.istio-ingress.svc/index.html
# CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml

## switch v1
k apply -n sock-shop -f sock-shop/v1-route-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://gateway.istio-ingress.svc/index.html
# CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml

# 서킷브레이커 테스트
k apply -n sock-shop -f sock-shop/circuit-dr.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 10 -qps 0 -n 500 -loglevel Warning http://gateway.istio-ingress.svc/index.html
# CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml
```
