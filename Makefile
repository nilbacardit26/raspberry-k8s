context = default

nginx-ingress-deploy-baremetal:
	helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --wait --kube-context $(context) --values nginx-ingress/values.yaml

nginx-upgrade:
	helm upgrade ingress-nginx ingress-nginx/ingress-nginx --kube-context $(context) --wait --install --values nginx-ingress/values.yaml -n ingress-nginx

purge-nginx:
	helm delete --kube-context $(context) ingress-nginx -n ingress-nginx

cert-manager-deploy:
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.3 --set installCRDs=true
	kubectl apply -f cert-manager/cluster_issuer.yaml

nfs-provisioner-upgrade:
	helm upgrade --install nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --wait --values nfs-provisioner/values.yaml

prometheus-deployment:
	helm install --wait --kube-context $(context) prometheus prometheus-community/prometheus --values ./prometheus/values.yaml -n prometheus
	kubectl apply -f prometheus/server/pv.yaml
	kubectl apply -f prometheus/server/pvc.yaml
	kubectl apply -f prometheus/alertmanager/pv.yaml
	kubectl apply -f prometheus/alertmanager/pvc.yaml
	kubectl apply -f prometheus/pushgateway/pv.yaml
	kubectl apply -f prometheus/pushgateway/pvc.yaml

prometheus-debug:
	helm install --wait --kube-context $(context) prometheus prometheus-community/prometheus --values ./prometheus/values.yaml --dry-run --debug

prometheus-purge:
	helm delete --kube-context $(context) prometheus -n prometheus

kube-metrics:
	helm install --wait --kube-context $(context) kube-metrics stable/kube-state-metrics --set image.repository=carlosedp/kube-state-metrics --set image.tag=v1.9.6 -n prometheus

grafana-deployment:
	kubectl apply -f grafana/pv.yaml
	kubectl apply -f grafana/pvc.yaml
	helm install --wait --kube-context $(context) grafana grafana/grafana -n grafana --values ./grafana/values.yaml


grafana-debug:
	helm install --wait --kube-context $(context) grafana grafana/grafana -n grafana --values ./grafana/values.yaml --dry-run --debug

# Crear el secret grafana, mirar els values
grafana-upgrade:
	helm upgrade --install --wait --kube-context $(context) grafana grafana/grafana -n grafana --values ./grafana/values.yaml

grafana-purge:
	helm delete --kube-context $(context) -n grafana grafana

redis-upgrade:
	helm upgrade --wait --kube-context $(context) --timeout=200s --install --values ./redis/redis_values.yaml redis stable/redis -n owncloud

owncloud-deploy:
	helm upgrade --install --wait --timeout 1200s --kube-context $(context) --install owncloud ./owncloud -n owncloud

owncloud-debug:
	helm upgrade --wait --kube-context $(context) --install owncloud ./owncloud -n owncloud --dry-run --debug

purge-owncloud:
	helm delete --kube-context $(context) owncloud -n owncloud

owncloud-recreate:
	helm upgrade --wait --recreate-pods --kube-context $(context) --install owncloud ./owncloud -n owncloud
