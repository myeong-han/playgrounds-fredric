## Check Point: How to using External Cassandra Database
> OS: Ubuntu 22.04   
> Cluster Version: (K3s) v1.28.6+k3s2   
> Chart Version: bitnami/jaeger:1.11.2

### 전제조건
1. `values.yaml` 수정 후 `helm install`
2. 사전에 Cassandra 유저 생성 (`CREATE USER bn_jaeger WITH PASSWORD 'jaeger' SUPERUSER;`)

### 1. `externalDatabase.exsistingSecret`과 `externalDatabase.existingSecretPasswordKey`를 미입력한 경우 (`externalDatabase.dbUser.password`를 사용하고 싶은 경우)
values.yaml
```yaml
externalDatabase:
  host: cassandra.datastore.svc
  port: 9042
  dbUser:
    user: bn_jaeger
    password: jaeger
  existingSecret: ""
  existingSecretPasswordKey: ""
  cluster:
    datacenter: "datacenter1"
  keyspace: "jaeger"
```
#### 1-1. `helm install` 실패
```console
helm install -n monitoring jaeger .

Error: INSTALLATION FAILED: 4 errors occurred:
        * Deployment.apps "jaeger-query" is invalid: [spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef.key: Required value, spec.template.spec.initContainers[0].env[4].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.initContainers[0].env[4].valueFrom.secretKeyRef.key: Required value]
        * Deployment.apps "jaeger--agent" is invalid: [spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef.key: Required value, spec.template.spec.initContainers[0].env[4].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.initContainers[0].env[4].valueFrom.secretKeyRef.key: Required value]
        * Deployment.apps "jaeger-collector" is invalid: [spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef.key: Required value, spec.template.spec.initContainers[0].env[4].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.initContainers[0].env[4].valueFrom.secretKeyRef.key: Required value]
        * Job.batch "jaeger-migrate" is invalid: [spec.template.spec.containers[0].env[6].valueFrom.secretKeyRef.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*'), spec.template.spec.containers[0].env[6].valueFrom.secretKeyRef.key: Required value]
```

### 2. secret을 사용하고 keyspace를 `bitnami_jaeger`가 아닌 이름으로 지정한 경우
values.yaml
```yaml
externalDatabase:
  host: cassandra.datastore.svc
  port: 9042
  dbUser:
    user: bn_jaeger
    password: jaeger
  existingSecret: jaeger-secrets
  existingSecretPasswordKey: cassandra_jaeger
  cluster:
    datacenter: "datacenter1"
  keyspace: "jaeger"
```
secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jaeger-secrets
  namespace: monitoring
type: Opaque
data:
  cassandra_jaeger: amFlZ2VyCg==
```
secret 생성 후 재설치
```console
kubectl apply -f secret.yaml
helm uninstall -n monitoring jaeger
helm install -n monitoring jaeger .

NAME: jaeger
LAST DEPLOYED: Sun Apr 14 12:39:11 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: jaeger
CHART VERSION: 1.11.2
APP VERSION: 1.55.0

** Please be patient while the chart is being deployed **

1. Get the application URL by running these commands:
    echo "Browse to http://127.0.0.1:8080"
    kubectl port-forward svc/jaeger 8080:16686 &

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - agent.resources
  - collector.resources
  - migration.resources
  - query.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
```
#### 2-1. db스키마 마이그레이션 성공
```console
kubectl logs -n monitoring jaeger-migrate-kkj8t

Defaulted container "jaeger-cassandra-migrator" out of: jaeger-cassandra-migrator, jaeger-cassandra-schema-grabber (init)
 03:42:23.13 INFO  ==> Connecting to the Cassandra instance cassandra.datastore.svc:9042
WARNING: cqlsh was built against 4.0.12, but this server is 4.1.4.  All features may not work!
 03:42:23.76 INFO  ==> Connection check success
Checking if Cassandra is up at cassandra.datastore.svc:9042.
WARNING: cqlsh was built against 4.0.12, but this server is 4.1.4.  All features may not work!

system       system_distributed  system_traces  system_virtual_schema
system_auth  system_schema       system_views

Cassandra connection established.
Cassandra version detected:
4
Generating the schema for the keyspace jaeger and datacenter datacenter1.
Using template file /cassandra-schema/v004.cql.tmpl with parameters:
    mode = test
    datacenter = datacenter1
    keyspace = jaeger
    replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
    trace_ttl = 172800
    dependencies_ttl = 0
    compaction_window_size = 96
    compaction_window_unit = MINUTES
WARNING: cqlsh was built against 4.0.12, but this server is 4.1.4.  All features may not work!
Schema generated.
```
#### 2-2. 애플리케이션 init 무한로딩
```console
kubectl get pods -n monitoring
NAME                                                  READY   STATUS     RESTARTS      AGE
jaeger-collector-5ffbfc87f7-77rjk                     0/1     Init:0/1   0             96s
jaeger-query-7c5db599b4-btmrr                         0/1     Init:0/1   0             96s
jaeger--agent-cff9858b4-4bfnw                         0/1     Init:0/1   0             96s
```
### 3. secret을 사용하고 keyspace를 `bitnami_jaeger`로 사용한 경우
values.yaml
```yaml
externalDatabase:
  host: cassandra.datastore.svc
  port: 9042
  dbUser:
    user: bn_jaeger
    password: jaeger
  existingSecret: jaeger-secrets
  existingSecretPasswordKey: jaeger-cassandra
  cluster:
    datacenter: "datacenter1"
  keyspace: "bitnami_jaeger"
```
#### 3-1. db스키마 마이그레이션 성공
```console
helm uninstall -n monitoring jaeger
helm install -n monitoring jaeger .

NAME: jaeger
LAST DEPLOYED: Sun Apr 14 12:58:58 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: jaeger
CHART VERSION: 1.11.2
APP VERSION: 1.55.0

** Please be patient while the chart is being deployed **

1. Get the application URL by running these commands:
    echo "Browse to http://127.0.0.1:8080"
    kubectl port-forward svc/jaeger 8080:16686 &

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - agent.resources
  - collector.resources
  - migration.resources
  - query.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

---
kubectl logs -n monitoring jaeger-migrate-p5vhr

Defaulted container "jaeger-cassandra-migrator" out of: jaeger-cassandra-migrator, jaeger-cassandra-schema-grabber (init)
 03:58:59.17 INFO  ==> Connecting to the Cassandra instance cassandra.datastore.svc:9042
WARNING: cqlsh was built against 4.0.12, but this server is 4.1.4.  All features may not work!
 03:58:59.81 INFO  ==> Connection check success
Checking if Cassandra is up at cassandra.datastore.svc:9042.
WARNING: cqlsh was built against 4.0.12, but this server is 4.1.4.  All features may not work!

bitnami_jaeger  system_auth         system_schema  system_views
system          system_distributed  system_traces  system_virtual_schema

Cassandra connection established.
Cassandra version detected:
4
Generating the schema for the keyspace bitnami_jaeger and datacenter datacenter1.
Using template file /cassandra-schema/v004.cql.tmpl with parameters:
    mode = test
    datacenter = datacenter1
    keyspace = bitnami_jaeger
    replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
    trace_ttl = 172800
    dependencies_ttl = 0
    compaction_window_size = 96
    compaction_window_unit = MINUTES
WARNING: cqlsh was built against 4.0.12, but this server is 4.1.4.  All features may not work!
Schema generated.
```
#### 3-2. agent 성공, query 및 collector 실패
```console
kubectl get pods -n monitoring

NAME                                                  READY   STATUS             RESTARTS      AGE
jaeger-collector-c5d957f58-jfbb5                      0/1     CrashLoopBackOff   1 (20s ago)   53s
jaeger--agent-c7c8cd779-kjpgc                         1/1     Running            0             53s
jaeger-query-7cc49b77c5-s892q                         0/1     Error              2 (20s ago)   53s

kubectl logs -n monitoring deployments/jaeger-collector | tail -n 10

Found 3 pods, using pod/jaeger--agent-c7c8cd779-kjpgc
Defaulted container "jaeger-agent" out of: jaeger-agent, jaeger-cassandra-ready-check (init)
{"level":"info","ts":1713066564.8704302,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to IDLE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066564.8705127,"caller":"grpc@v1.62.0/clientconn.go:1223","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to CONNECTING","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066564.8705347,"caller":"grpc@v1.62.0/clientconn.go:1338","msg":"[core][Channel #1 SubChannel #2] Subchannel picks a new address \"jaeger-collector:14250\" to connect","system":"grpc","grpc_log":true}
{"level":"warn","ts":1713066564.8711421,"caller":"grpc@v1.62.0/clientconn.go:1400","msg":"[core][Channel #1 SubChannel #2] grpc: addrConn.createTransport failed to connect to {Addr: \"jaeger-collector:14250\", ServerName: \"jaeger-collector:14250\", }. Err: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066564.8711627,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to TRANSIENT_FAILURE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.7186525,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to IDLE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.718753,"caller":"grpc@v1.62.0/clientconn.go:1223","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to CONNECTING","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.7187653,"caller":"grpc@v1.62.0/clientconn.go:1338","msg":"[core][Channel #1 SubChannel #2] Subchannel picks a new address \"jaeger-collector:14250\" to connect","system":"grpc","grpc_log":true}
{"level":"warn","ts":1713066609.7201135,"caller":"grpc@v1.62.0/clientconn.go:1400","msg":"[core][Channel #1 SubChannel #2] grpc: addrConn.createTransport failed to connect to {Addr: \"jaeger-collector:14250\", ServerName: \"jaeger-collector:14250\", }. Err: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.7201433,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to TRANSIENT_FAILURE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}

kubectl logs -n monitoring deployments/jaeger-query | tail -n 10

Found 3 pods, using pod/jaeger--agent-c7c8cd779-kjpgc
Defaulted container "jaeger-agent" out of: jaeger-agent, jaeger-cassandra-ready-check (init)
{"level":"info","ts":1713066609.7186525,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to IDLE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.718753,"caller":"grpc@v1.62.0/clientconn.go:1223","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to CONNECTING","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.7187653,"caller":"grpc@v1.62.0/clientconn.go:1338","msg":"[core][Channel #1 SubChannel #2] Subchannel picks a new address \"jaeger-collector:14250\" to connect","system":"grpc","grpc_log":true}
{"level":"warn","ts":1713066609.7201135,"caller":"grpc@v1.62.0/clientconn.go:1400","msg":"[core][Channel #1 SubChannel #2] grpc: addrConn.createTransport failed to connect to {Addr: \"jaeger-collector:14250\", ServerName: \"jaeger-collector:14250\", }. Err: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066609.7201433,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to TRANSIENT_FAILURE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066676.0113776,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to IDLE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066676.0114605,"caller":"grpc@v1.62.0/clientconn.go:1223","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to CONNECTING","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066676.0114727,"caller":"grpc@v1.62.0/clientconn.go:1338","msg":"[core][Channel #1 SubChannel #2] Subchannel picks a new address \"jaeger-collector:14250\" to connect","system":"grpc","grpc_log":true}
{"level":"warn","ts":1713066676.0122693,"caller":"grpc@v1.62.0/clientconn.go:1400","msg":"[core][Channel #1 SubChannel #2] grpc: addrConn.createTransport failed to connect to {Addr: \"jaeger-collector:14250\", ServerName: \"jaeger-collector:14250\", }. Err: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
{"level":"info","ts":1713066676.012293,"caller":"grpc@v1.62.0/clientconn.go:1225","msg":"[core][Channel #1 SubChannel #2] Subchannel Connectivity change to TRANSIENT_FAILURE, last error: connection error: desc = \"transport: Error while dialing: dial tcp 10.43.40.134:14250: connect: connection refused\"","system":"grpc","grpc_log":true}
```
### 4. deployment를 수정하여 password env를 직접 입력한 경우
```console
kubectl edit deployments.apps -n monitoring jaeger-query
...Before
        - name: CASSANDRA_PASSWORD
          valueFrom:
            secretKeyRef:
              key: cassandra_jaeger
              name: jaeger-secrets
...After
        - name: CASSANDRA_PASSWORD
          value: jaeger

kubectl edit deployments.apps -n monitoring jaeger-collector
...Before
        - name: CASSANDRA_PASSWORD
          valueFrom:
            secretKeyRef:
              key: cassandra_jaeger
              name: jaeger-secrets
...After
        - name: CASSANDRA_PASSWORD
          value: jaeger
```
#### 4-1. 성공
```console
kubectl get pods -n monitoring
NAME                                                  READY   STATUS    RESTARTS      AGE
jaeger--agent-c7c8cd779-kjpgc                         1/1     Running   0             7m15s
jaeger-query-546cd76cc9-7qtm4                         1/1     Running   0             47s
jaeger-collector-79f7d979bb-8rccn                     1/1     Running   0             22s

```