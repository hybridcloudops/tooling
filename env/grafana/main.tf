variable "minikube_ip" {
  default = "TBD"
}

variable "bsc_ask_lb_ip" {
  default = "TBD"
}

provider "grafana" {
  url  = "http://${var.minikube_ip}:30005"
  auth = "admin:admin"
}

resource "grafana_data_source" "prom_minikube" {
  type          = "prometheus"
  name          = "prom_minikube"
  url           = "http://${var.minikube_ip}:30006"
}

resource "grafana_data_source" "prom_bsc_aks" {
  type          = "prometheus"
  name          = "prom_bsc_aks"
  url           = "http://${var.bsc_ask_lb_ip}:9090"
}

resource "grafana_dashboard" "service_health" {
  config_json = file("dashboards/service-health.json")
}

resource "grafana_dashboard" "minikube_cluster" {
  config_json = file("dashboards/kube_cluster_minikube.json")
}

resource "grafana_dashboard" "aks_cluster" {
  config_json = file("dashboards/kube_cluster_aks.json")
}

resource "grafana_dashboard" "deployments" {
  config_json = file("dashboards/deployments.json")
}


