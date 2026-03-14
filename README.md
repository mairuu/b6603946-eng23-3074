create cluster with kind:

```bash
kind create cluster --config=kind.yaml
```

install nginx ingress controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

wait for the nginx ingress controller to be ready:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

devops-tools:

```bash
kubectl apply -f devops-tools/namespace.yaml
kubectl apply -f devops-tools/pv.yaml
kubectl apply -f devops-tools/pvc.yaml
kubectl apply -f devops-tools/jenkins.yaml
kubectl apply -f devops-tools/ingress.yaml
```

wait for Jenkins to be ready

```bash
kubectl wait --namespace devops-tools \
  --for=condition=ready pod \
  --selector=app=jenkins \
  --timeout=300s
```

get the initial admin password:

```bash
kubectl exec -n devops-tools -it deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

## using the makefile

you can automate all the above steps using the provided `Makefile`:

- `make all`: creates the cluster, installs the nginx ingress controller, deploys jenkins, and fetches the admin password.
- `make clean`: destroys the kind cluster when you are done.
