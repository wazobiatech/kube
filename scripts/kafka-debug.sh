#!/bin/bash

# Kafka Debugging Script
# Usage: ./kafka-debug.sh [namespace]

# Set namespace
NAMESPACE=${1:-default}
echo "Using namespace: $NAMESPACE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\n${YELLOW}=== Kafka Debug Script ===${NC}\n"

# Get all pods
echo -e "${YELLOW}=== Checking all pods in namespace ===${NC}"
kubectl get pods -n $NAMESPACE
echo ""

# Specifically get Kafka and Zookeeper pods
echo -e "${YELLOW}=== Identifying Kafka and Zookeeper pods ===${NC}"
KAFKA_PODS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/component=kafka -o name)
ZK_PODS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/component=zookeeper -o name)

if [ -z "$KAFKA_PODS" ]; then
  echo -e "${RED}No Kafka pods found!${NC}"
else
  echo -e "${GREEN}Found Kafka pods:${NC}"
  echo "$KAFKA_PODS"
fi

if [ -z "$ZK_PODS" ]; then
  echo -e "${RED}No Zookeeper pods found!${NC}"
else
  echo -e "${GREEN}Found Zookeeper pods:${NC}"
  echo "$ZK_PODS"
fi
echo ""

# Check Services
echo -e "${YELLOW}=== Checking Kafka-related services ===${NC}"
kubectl get svc -n $NAMESPACE | grep -E 'kafka|zookeeper'
echo ""

# Check StatefulSets
echo -e "${YELLOW}=== Checking StatefulSets ===${NC}"
kubectl get statefulsets -n $NAMESPACE
echo ""

# Check PVCs
echo -e "${YELLOW}=== Checking PVCs ===${NC}"
kubectl get pvc -n $NAMESPACE | grep -E 'kafka|zookeeper'
echo ""

# Check ConfigMaps
echo -e "${YELLOW}=== Checking ConfigMaps ===${NC}"
kubectl get configmaps -n $NAMESPACE | grep -E 'kafka|zookeeper'
echo ""

# Function to check pod health
check_pod_details() {
  POD=$1
  echo -e "${YELLOW}=== Details for pod $POD ===${NC}"
  kubectl describe pod $POD -n $NAMESPACE
  echo ""
  
  echo -e "${YELLOW}=== Logs for pod $POD ===${NC}"
  kubectl logs $POD -n $NAMESPACE --tail=100
  echo ""
}

# Check Pod Details if found
if [ ! -z "$KAFKA_PODS" ]; then
  FIRST_KAFKA_POD=$(echo "$KAFKA_PODS" | head -n 1)
  check_pod_details $FIRST_KAFKA_POD
  
  echo -e "${YELLOW}=== Testing Kafka broker connectivity ===${NC}"
  kubectl exec $FIRST_KAFKA_POD -n $NAMESPACE -- bash -c "echo 'Testing Kafka broker connectivity'; nc -vz localhost 9092 || echo 'Failed to connect to local broker'"
  
  echo -e "${YELLOW}=== Testing Zookeeper connectivity from Kafka ===${NC}"
  kubectl exec $FIRST_KAFKA_POD -n $NAMESPACE -- bash -c "echo 'Testing Zookeeper connectivity'; nc -vz \$KAFKA_ZOOKEEPER_CONNECT || echo 'Failed to connect to Zookeeper'"
  
  echo -e "${YELLOW}=== Testing DNS resolution from Kafka pod ===${NC}"
  kubectl exec $FIRST_KAFKA_POD -n $NAMESPACE -- bash -c "echo 'Testing hostname resolution'; hostname -f; nslookup \$(hostname -f) || echo 'Failed to resolve hostname'"
fi

if [ ! -z "$ZK_PODS" ]; then
  FIRST_ZK_POD=$(echo "$ZK_PODS" | head -n 1)
  check_pod_details $FIRST_ZK_POD
  
  echo -e "${YELLOW}=== Testing Zookeeper connectivity ===${NC}"
  kubectl exec $FIRST_ZK_POD -n $NAMESPACE -- bash -c "echo 'Testing Zookeeper server'; nc -vz localhost 2181 || echo 'Failed to connect to local Zookeeper'"
  
  echo -e "${YELLOW}=== Testing DNS resolution from Zookeeper pod ===${NC}"
  kubectl exec $FIRST_ZK_POD -n $NAMESPACE -- bash -c "echo 'Testing hostname resolution'; hostname -f; nslookup \$(hostname -f) || echo 'Failed to resolve hostname'"
fi

# Check environment variables
if [ ! -z "$KAFKA_PODS" ]; then
  FIRST_KAFKA_POD=$(echo "$KAFKA_PODS" | head -n 1)
  echo -e "${YELLOW}=== Checking Kafka environment variables ===${NC}"
  kubectl exec $FIRST_KAFKA_POD -n $NAMESPACE -- bash -c "printenv | grep -E 'KAFKA|ZOO'"
  echo ""
fi

if [ ! -z "$ZK_PODS" ]; then
  FIRST_ZK_POD=$(echo "$ZK_PODS" | head -n 1)
  echo -e "${YELLOW}=== Checking Zookeeper environment variables ===${NC}"
  kubectl exec $FIRST_ZK_POD -n $NAMESPACE -- bash -c "printenv | grep -E 'ZOO|KAFKA'"
  echo ""
fi

echo -e "${YELLOW}=== Debugging completed ===${NC}"