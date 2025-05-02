#!/bin/bash
# cleanup-and-reinstall.sh - Remove all resources and redeploy from scratch

# Set text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting complete cleanup of Kubernetes resources...${NC}"

# 1. Delete Helm releases
echo -e "${YELLOW}Uninstalling Helm releases...${NC}"
helm uninstall hivedeck --namespace kube-dev || true
helm uninstall ingress-nginx --namespace ingress-nginx || true

# 2. Delete namespaces (this removes all resources in them)
echo -e "${YELLOW}Deleting namespaces...${NC}"
kubectl delete namespace kube-dev --timeout=60s || true
kubectl delete namespace ingress-nginx --timeout=60s || true
kubectl delete namespace metallb-system --timeout=60s || true

# 3. Force delete any stuck namespaces
echo -e "${YELLOW}Checking for stuck namespaces...${NC}"
for ns in kube-dev ingress-nginx metallb-system; do
  if kubectl get namespace $ns > /dev/null 2>&1; then
    echo -e "${RED}Namespace $ns is stuck, force removing...${NC}"
    kubectl get namespace $ns -o json | \
      jq '.spec.finalizers = []' | \
      kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -
  fi
done

# 4. Wait until namespaces are fully gone
echo -e "${YELLOW}Waiting for namespaces to be completely removed...${NC}"
for ns in kube-dev ingress-nginx metallb-system; do
  while kubectl get namespace $ns > /dev/null 2>&1; do
    echo -e "Waiting for $ns to be deleted..."
    sleep 5
  done
done

echo -e "${GREEN}Clean-up complete. Starting fresh installation...${NC}"