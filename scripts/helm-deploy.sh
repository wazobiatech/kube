#!/bin/bash
ENV=${1:-dev}

# First install/upgrade custom NGINX Ingress Controller
echo "Installing custom NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ../charts/ingress \
  --namespace ingress-nginx \
  --create-namespace

# Wait for the controller to be ready
echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s || echo "Warning: Timed out waiting for ingress controller"

# Then deploy/upgrade the application
echo "Deploying application for environment: ${ENV}..."
helm upgrade --install hivedeck ../charts/kube \
  -f ../environments/values-${ENV}.yaml \
  --namespace kube-${ENV} --create-namespace