# sockshop-istio
### 사전 설정
1. istio-ingress svc의 Cluster-IP를 구한다 ex)`k get svc -n istio-system`
2. `vi util_fortio.yaml` 내에서 `.spec.template.spec.hostAliases[0].ip`의 값을 위의 값으로 수정한다.

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
#test-abort ns gw & vs
k apply -n sock-shop -f sock-shop/abort.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop/catalogue

#test-delay ns gw & vs
k apply -n sock-shop -f sock-shop/delay.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop/catalogue

#test-canary ns gw & vs
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop.canary/index.html

#test-bluegreen ns gw & vs
## switch v2
k apply -n sock-shop -f sock-shop/v2-route.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop/index.html

## switch v1
k apply -n sock-shop -f sock-shop/v1-route.yaml
k exec -it deploy/fortio-deploy -c fortio -- fortio load -c 3 -qps 0 -n 500 -loglevel Warning http://sock.shop/index.html

## CLEAN
k apply -n sock-shop -f sock-shop/init/ingress-gateway.yaml -f sock-shop/init/vs.yaml
```
