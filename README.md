kind create cluster -n teemii --config kind-config.yaml

wait for teemii-frontend to appear before adding taints
kubectl -n kube-system get pods -o wide | grep kube-proxy 

./apply_taints.sh

cd k8s/base
kubectl apply -f ./namespace.yaml
kubectl apply -f ./backend
kubectl apply -f ./frontend

kubectl get pods -n teemii

## Observability

# Set up prometheus
kubectl apply -f observability/namespace.yaml
kubectl apply -f observability/exporters
kubectl apply -f observability/prometheus

kubectl -n observability port-forward service/prometheus-service --address 0.0.0.0 --address :: 9090:9090

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana -f grafana-values.yaml -n observability
helm upgrade grafana grafana/grafana -n observability -f ./grafana-values.yaml

# Access Grafana
kubectl get secret --namespace observability grafana -o jsonpath="{.data.admin-password}"| base64 --decode
kubectl port-forward -n observability service/grafana 3000:80 --address 0.0.0.0

Add loki and prometheus as data sources in grafana

# Install Loki
helm install loki grafana/loki -n observability -f observability/logs/loki/loki-values.yaml
helm upgrade loki grafana/loki -n observability -f observability/logs/loki/loki-values.yaml
# Set up Promtail 
kubectl apply -n observability -f observability/logs/promtail

