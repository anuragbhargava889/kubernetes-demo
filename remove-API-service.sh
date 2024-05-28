#!/bin/sh
set -e

kubectl delete -f api-config.yaml
kubectl delete -f api-secret.yaml
kubectl delete -f api-replicaset.yaml
kubectl delete -f api-service.yaml
kubectl delete -f api-hpa.yaml
