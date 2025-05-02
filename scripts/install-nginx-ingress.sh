#!/bin/bash
# Script to install NGINX Ingress Controller

# Create namespace
kubectl apply -f templates/nginx-ingress/namespace.yaml

# Create ConfigMap
kubectl apply -f templates/nginx-ingress/config.yaml

# Create IngressClass
kubectl apply -f templates/nginx-ingress/ingress-class.yaml

# Create Deployment
kubectl apply -f templates/nginx-ingress/controller.yaml

# Create Service
kubectl apply -f templates/nginx-ingress/service.yaml

# Wait for the controller to be ready
echo "Waiting for NGINX Ingress Controller pods to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "NGINX Ingress Controller has been installed successfully!"
echo "You can access your applications via NodePort (80:30080, 443:30443)"
echo "Make sure your DNS records point to your server IP address."