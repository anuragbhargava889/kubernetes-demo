#!/bin/sh
set -e

kubectl apply -f mysql-config.yaml
kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f mysql-headless-service.yaml
