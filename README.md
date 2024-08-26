# the Fredric: k3s infra & service Playground

playgrounds fredric is a collection of k3s-based service infrastructure IAC for private testing of my personal projects.

## Architecture
### total Infra
```mermaid
flowchart LR
    A((Fredric's Playground))-->B((IaaS: on-premise K3s)):::_node
        B--KVM Provider-->B11[kubevirt]:::_container
        B--Automation-->B21[opentofu]:::_container
        B--VPN-->B31[openvpn]:::_container
        B--DNS-->B41[dnsmasq]:::_container
        B--LoadBalancer-->B51[metallb]:::_container
        B-->B6[Utility]
            B6--IAM--->B611[keycloak]:::_container
            B6--Certification: TLS Management-->B621[cert-manager]:::_container
            B6--Secret Management-->B631[infisical]:::_container
        B-->B7[Observability]
            B7--Dashboard-->grafana[grafana]:::_container
            %% B7-->B72[Collector]
            B7-->B721[fluentd]:::_container
            B7-->B722[tempo]:::_container
            B7-->B723[loki]:::_container
            %% B7-->B73[Store]
            B7-->B731[OpenSearch]:::_container
            B7-->B732[thanos]:::_container
    A-->E((Github)):::_public
    E--mirroring in gitea-->E1[repository]:::_public
    E--deploy test-->E2[actions]:::_public
    E--helm chart repository-->E3[page]:::_public
    B11-.->C((PaaS: myCluster)):::_node
        C-->C1[Container Platform]
            C1--Container Runtime-->C111[gvisor]:::_node
            C1--CNI-->C121[cilium]:::_container
            C1--CSI / object-Storage-->C1311[rook]:::_container
            %% C1-->C14[Security & Compliance]
            C1--Security-->C141[tetragon]:::_container
            C1--Compliance-->C142[opa]:::_container
        C-->C2[Contents OSS]
            C2--WebDAV NAS-->C211[nextcloud]:::_container
            C2-->C22[Game Hosting]
                C22-->C221[minecraft]:::_container
                C22-->C222[palworld-server-docker]:::_container
        C-->C3[DevOps]
            C3--API Gateway-->C311[emissary-igress]:::_container
            C3--Service Mesh-->C312[istio]:::_container
                C312-->C3121[envoy]
            C3-->Git-->C322[gitea]:::_container
            C3--CI: 테스트/빌드자동화-->C332[argo-ci]
                C332-->C3321[argo-workflows]:::_container
                C332-->C3322[argo-events]:::_container
            C3--CD: 배포자동화-->C341[argo-cd]:::_container
            C3--Artifact Repository & Container Image-->C351[nexus-repository-manager]:::_container
            C3--Observerbility-->C361[prometheus]:::_container
        C-->C4[Service]
            C4-->C41[Nginx]:::_application
                C41-->C411[react-webpack]:::_application
            C4--API Modules-->C421[auth-module]:::_application
            C4--API Modules-->C422[java or golang]:::_application
            C4--RDB-->C431[postgres]:::_container
            C4--Message Broker-->C441[kafka]:::_container
    B11-.->D((Windows VDI)):::_node

    B31-.->B41
    B21-. Provisioning Infra .->B11
    B731-.->C1311
    B731-.->grafana
    B732-.->C1311
    B732-.->grafana
    B722-.->grafana
    B723-.->grafana
    B721-.->B731
    C3121-.->B722
    C311<-. AuthN & AuthZ .->B611
    C421<-. AuthN & AuthZ .->B611
    C361-.->B732
    B51-. LoadBalancer Service .->C311
    C311-.->C41
    C411<-.->C421
    C411<-.->C422
    C411-.->C441
    C441-.->C422
    C421-.->C431
    C422-.->C431
    C322-.Event trigger.->C3322
    C3322-.Build Container.->C3321
    C3321-.Push Image.->C351
    C351-.Continuous Deploy.->C341

    classDef _public stroke:#F0F,fill:#515
    classDef _application stroke:#FF0,fill:#551
    classDef _container stroke:#0FF,fill:#155
    classDef _node stroke:#F00,fill:#511
```
### Micro-frontend for SEO
```mermaid
flowchart LR
	subgraph hostmodule
		direction TB
		www.aaa.com --> nginx
		NextJS -.Resoucre Caching,
			LoadBalancing.-> nginx
		nginx -.Proxy.-> NextJS
	end
	direction TB
		Search --SEO-->	hostmodule
	hostmodule -.webpack5 MF.-> module1[한국투자증권 예약투자 앱-CSR NextJS]
	hostmodule -.webpack5 MF.-> module2[Notion 기반 블로그 문서-SSR NextJS]
	hostmodule -.webpack5 MF.-> module3[동영상 스트리밍 사이트-SSR NextJS]
```

## Installation

```bash
#todo
```

## Usage

```bash
#todo
```
