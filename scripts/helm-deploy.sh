#!/bin/bash
ENV=${1:-dev}

# Create metallb namespace
echo "Setting up MetalLB..."
kubectl apply -f ../charts/kube/templates/metallb/namespace.yaml

# Deploy MetalLB resources
kubectl apply -f ../charts/kube/templates/metallb/resources.yaml

# Wait for MetalLB to be ready
echo "Waiting for MetalLB to be ready..."
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s || echo "Warning: Timed out waiting for MetalLB"

# Apply MetalLB configuration
kubectl apply -f ../charts/kube/templates/metallb/addresspool.yaml
kubectl apply -f ../charts/kube/templates/metallb/l2advertisement.yaml

# Install/upgrade custom NGINX Ingress Controller
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

# Deploy/upgrade the application
echo "Deploying application for environment: ${ENV}..."
helm upgrade --install hivedeck ../charts/kube \
  -f ../environments/values-${ENV}.yaml \
  --namespace kube-${ENV} --create-namespace

echo "Deployment complete! Checking LoadBalancer services:"
kubectl get services -n kube-${ENV} | grep LoadBalancer