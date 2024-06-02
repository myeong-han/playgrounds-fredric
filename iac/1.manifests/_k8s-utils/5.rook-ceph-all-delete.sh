#!/bin/bash

helm uninstall -n rook-ceph rook-ceph-cluster
helm uninstall -n rook-ceph rook-ceph

#crd finalizer update
for CRD in $(kubectl get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do
    kubectl get -n rook-ceph "$CRD" -o name | \
    xargs -I {} kubectl patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": []}}'
done

sudo rm -rf /var/lib/rook

kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n rook-ceph
