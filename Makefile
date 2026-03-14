.PHONY: all cluster ingress devops-tools wait-jenkins password clean

all: cluster ingress devops-tools wait-jenkins password

cluster:
	@echo "creating kind cluster..."
	kind create cluster --config=kind.yaml

ingress:
	@echo "installing nginx ingress controller..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "waiting for nginx ingress controller to be ready..."
	sleep 5
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s
	@echo "waiting for admission webhook to be ready..."
	sleep 5

devops-tools:
	@echo "deploying devops-tools namespace and jenkins..."
	kubectl apply -f devops-tools/namespace.yaml
	kubectl apply -f devops-tools/pv.yaml
	kubectl apply -f devops-tools/pvc.yaml
	kubectl apply -f devops-tools/jenkins.yaml
	kubectl apply -f devops-tools/ingress.yaml

wait-jenkins:
	@echo "waiting for jenkins to be ready..."
	sleep 5
	kubectl wait --namespace devops-tools \
		--for=condition=ready pod \
		--selector=app=jenkins \
		--timeout=300s

password:
	@echo "retrieving jenkins initial admin password..."
	kubectl exec -n devops-tools -it deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword

clean:
	@echo "deleting kind cluster..."
	kind delete cluster
