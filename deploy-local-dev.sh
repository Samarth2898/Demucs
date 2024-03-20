#!/bin/sh
#
# You can use this script to launch Redis and minio on Kubernetes
# and forward their connections to your local computer. That means
# you can then work on your worker-server.py and rest-server.py
# on your local computer rather than pushing to Kubernetes with each change.
#
# To kill the port-forward processes us e.g. "ps augxww | grep port-forward"
# to identify the processes ids
#
# helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl apply -f redis/redis-deployment.yaml
kubectl apply -f redis/redis-service.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install -f ./minio/minio-config.yaml -n minio-ns --create-namespace minio-proj bitnami/minio

kubectl apply -f rest/rest-deployment.yaml
kubectl apply -f rest/rest-ingress.yaml
# kubectl apply -f rest/rest-ingress-gke.yaml
kubectl apply -f logs/logs-deployment.yaml
kubectl apply -f worker/worker-deployment.yaml
kubectl apply -f minio/minio-external-service.yaml


kubectl port-forward --address 0.0.0.0 service/redis 6379:6379 &
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.4/deploy/static/provider/cloud/deploy.yaml
# If you're using minio from the kubernetes tutorial this will forward those
# kubectl port-forward -n minio-ns --address 0.0.0.0 service/minio-proj 9000:9000 &
while true; do kubectl port-forward -n minio-ns --address 0.0.0.0 service/minio-proj 9001:9001; done &