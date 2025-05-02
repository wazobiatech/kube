# Kubernetes Debugging Guide

This guide includes useful commands to debug and inspect the status of your Kubernetes cluster.

---

## 🔍 Cluster Information

```bash
kubectl cluster-info                         # Show cluster master and services
kubectl get nodes                            # List all cluster nodes
kubectl describe node <node-name>            # Detailed node info (resources, labels, conditions)
kubectl version --short                      # Show client and server versions
```

---

## 🚦 Pod and Deployment Debugging

```bash
kubectl get pods -A                          # List all pods across namespaces
kubectl get pods -n <namespace>              # Pods in a specific namespace
kubectl describe pod <pod-name> -n <namespace>  # Details of a specific pod
kubectl logs <pod-name>                      # Logs from a pod
kubectl logs -f <pod-name>                   # Follow logs from a pod
kubectl logs <pod-name> -c <container-name>  # Logs from a specific container in a pod
kubectl exec -it <pod-name> -- /bin/sh       # Shell into a pod (or use /bin/bash)
```

---

## 🧠 Services, Endpoints, and Networking

```bash
kubectl get svc                              # List services
kubectl describe svc <service-name>          # Details about a service
kubectl get endpoints                        # Check if services are exposing endpoints
kubectl port-forward svc/<service-name> 8080:80  # Port forward service to localhost
kubectl get ingress                          # Inspect ingress resources
```

---

## ⚠️ Events and Errors

```bash
kubectl get events --sort-by='.metadata.creationTimestamp'  # Chronological events
kubectl describe pod <pod-name>                              # Shows error messages, restarts
```

---

## 📦 Deployments, ReplicaSets, and DaemonSets

```bash
kubectl get deployments                      # List deployments
kubectl describe deployment <name>           # Deployment details
kubectl rollout status deployment <name>     # Status of latest rollout
kubectl rollout history deployment <name>    # Show deployment history
kubectl get rs                               # ReplicaSets
kubectl get ds                               # DaemonSets
```

---

## 📁 YAML & Resources

```bash
kubectl get pod <name> -o yaml               # Output raw YAML config
kubectl get all -o wide                      # All resources with IPs and node info
```

---

## 🧰 System-Level & Cluster Component Debugging

```bash
# For k3s
sudo journalctl -u k3s -f                    # Follow k3s logs
sudo tail -f /var/log/syslog                 # General system logs

# Check kubelet logs (general Kubernetes nodes)
sudo journalctl -u kubelet -f

# Kubeconfig file location (for troubleshooting access issues)
echo $KUBECONFIG                             # Should point to ~/.kube/config or custom path
```

---

## 🧪 Test Network/DNS

```bash
kubectl run busybox --image=busybox --restart=Never -- sleep 3600
kubectl exec -it busybox -- nslookup kubernetes.default
kubectl exec -it busybox -- wget -O- http://kubernetes.default
```

---

## 🧼 Clean Up and Restart

```bash
kubectl delete pod <name>                   # Delete a pod (it will restart if part of a deployment)
kubectl rollout restart deployment <name>   # Restart a deployment
kubectl delete -f <file.yaml>               # Delete resource from YAML file
```

---

## 🧾 Check API Resources & Versions

```bash
kubectl api-resources                        # List all resource types
kubectl api-versions                         # List all API versions
```

---

## 📁 Common Kubeconfig Fixes

```bash
# Fix permissions (for k3s or root-only kubeconfig)
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

---

## Helm Commands

```bash
# Removes all pods in the namespace
helm uninstall kube --namespace kube-dev
```

## 💡 Tips

- Use `-A` or `--all-namespaces` when debugging to make sure you're not missing resources running in different namespaces.
- Combine `kubectl get` with `-o wide` to get IPs, node info, and container images.
- Use `watch kubectl get pods` to get a live refresh on pod states.

---

Happy debugging! 🛠️