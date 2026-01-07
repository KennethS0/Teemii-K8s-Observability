# K8s Observability
This repository contains a demonstration on how to configure different observability features such as node monitoring for metrics as well as logs monitoring. All this is visualized through Grafana. 

The application being monitored is based on a third party app called 'Teemii' that contains both frontend and backend containers.

## Set up the application
All the files needed to set up the application are in `k8s/base`, all the commands below are being executed in that specific folder.

1. Create the kind cluster: `kind create cluster -n teemii --config kind-config.yaml`
2. Apply taints: `./apply_taints`
3. Create the namespace: `kubectl apply -f ./namespace.yaml` 
4. Create backend: `kubectl apply -f ./backend`
5. Create frontend: `kubectl apply -f ./frontend`
6. Verify: `kubectl get pods -n teemii`

Once all the steps are done, there should be 2 frontend pods and 1 backend pod created, each in the specific worker-node defined.

## Set up observability
To monitor the state of our pods we are going to need several different tools, such as **Grafana** to visualize our data. Prometheus to capture metrics related to the pod's performance. **Loki** in order to query logs and **Promtail** to capture the logs and send them to Loki.  

First we need to create a namespace to have our observability pods apart from our application pods. All the commands from here on out are executed under the `k8s/observability` directory.

`kubectl apply -f namespace.yaml`

### Install Grafana
1. `helm repo add grafana https://grafana.github.io/helm-charts`
2. To set up Grafana for the first time: `helm install grafana grafana/grafana -f grafana/grafana-values.yaml -n observability`
3. To apply any changes to the Grafana config: `helm upgrade grafana grafana/grafana -n observability -f grafana/grafana-values.yaml`

#### Access Grafana
1. Save the password obtained from the following command: `kubectl get secret --namespace observability grafana -o jsonpath="{.data.admin-password}"| base64 --decode`
2. Access Grafana: `kubectl port-forward -n observability service/grafana 3000:80 --address 0.0.0.0`

### Set up Prometheus
1. Set up the exporters to be able to send data: `kubectl apply -f exporters`
2. Set up Prometheus: `kubectl apply -f prometheus`
3. Verify Prometheus: `kubectl -n observability port-forward service/prometheus-service --address 0.0.0.0 --address :: 9090:9090`

### Install Loki
1. `helm install loki grafana/loki -n observability -f logs/loki/loki-values.yaml`
2. `helm upgrade loki grafana/loki -n observability -f logs/loki/loki-values.yaml`

### Set up Promtail 
1.`1kubectl apply -n observability -f logs/promtail`

### View Prometheus and Loki in Grafana
Prometheus and Loki need to be added as data sources in Grafana to view the data. To do this we need the name of the prometheus service and the port where it is running, same thing with loki.