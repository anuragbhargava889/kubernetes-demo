#!/bin/sh
set -e

kubectl apply -f api-config.yaml
kubectl apply -f api-secret.yaml
kubectl apply -f api-replicaset.yaml
kubectl apply -f api-service.yaml
