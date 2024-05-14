# sockshop-istio
### 사전 설정
1. istio-ingress svc의 Cluster-IP를 구한다 ex)`k get svc -n istio-system`
2. `vi util_fortio.yaml` 내에서 `.spec.template.spec.hostAliases[0].ip`의 값을 위의 값으로 수정한다.
#### 사용할 Domain HostName
```
sock.shop.default
sock.shop.canary
```

### configuering
```bash                                                                                                                        
#global
kubectl apply -f ns.yaml
kubectl apply -f util_fortio.yaml #in default namespace

#sock-shop ns application & dr
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/v1-deploy.yaml -f sock-shop/init/v2-deploy.yaml -f sock-shop/init/vs.yaml

#sock-shop-canary ns gw & vs
k apply -n sock-shop-canary -f sock-shop-canary/ingress-gateway.yaml
```


abort.yaml  circuit-dr.yaml  delay.yaml  init  mtls-dr.yaml  v1-route.yaml  v2-route.yaml

### TEST
```bash
#test abort fault injection
k apply -n sock-shop -f sock-shop/abort-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop.default/catalogue

#test delay fault injection
k apply -n sock-shop -f sock-shop/delay-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop.default/catalogue

#test canary deploy
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop.canary/index.html

#test bluegreen deploy
## switch v2
k apply -n sock-shop -f sock-shop/v2-route-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop.default/index.html

## switch v1
k apply -n sock-shop -f sock-shop/v1-route-vs.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop.default/index.html

#test http1MaxPendingRequests 제한하기: 2 connection
k apply -n sock-shop -f sock-shop/circuit-dr.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 10 -qps 0 -n 500 -loglevel Warning http://sock.shop.default/index.html
# 대략적으로 10connection중 8개가 pending불가이므로 20%성공

## CLEAN
k apply -n sock-shop -f sock-shop/init/dr.yaml -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml
```
