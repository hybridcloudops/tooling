# Monitoring

When running on minikube:

Open the UI for Grafana
```
minikube service --namespace=monitoring grafana
```

Open the UI for Prometheus
```
minikube service --namespace=monitoring prometheus
```

Open the UI for Prometheus Pushgateway
```
minikube service --namespace=monitoring prometheus-pushgateway
```