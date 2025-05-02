#!/bin/bash
# Deploy or upgrade the entire cluster with MetalLB and your applications

# Deploy MetalLB first
./deploy-metallb.sh

# Deploy or upgrade the Helm chart
echo "Deploying HiveDeck applications..."
helm upgrade --install hivedeck ./kube-hivedeck -f values.yaml -f values-dev.yaml

echo "Deployment complete! Checking LoadBalancer services:"
kubectl get services | grep LoadBalancer