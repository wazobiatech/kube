#!/bin/bash
# Deploy MetalLB on a Kubernetes cluster

# Create the namespace
kubectl apply -f metallb-namespace.yaml

# Deploy MetalLB components
kubectl apply -f metallb-resources.yaml

# Wait for the pods to be ready
echo "Waiting for MetalLB pods to be ready..."
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s

# Apply the MetalLB configuration
kubectl apply -f metallb-config.yaml

echo "MetalLB deployment complete!"