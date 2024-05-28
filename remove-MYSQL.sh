#!/bin/sh
set -e

kubectl delete -f mysql-config.yaml
kubectl delete -f mysql-secret.yaml
kubectl delete -f mysql-statefulset.yaml
kubectl delete -f mysql-headless-service.yaml
