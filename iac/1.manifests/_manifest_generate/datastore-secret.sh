kubectl create secret generic auth-secrets -n datastore --from-file=global --from-file=postgres --from-file=redis --from-file=cassandra-password
