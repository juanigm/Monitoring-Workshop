variable "services" {

  type = list(object({
    name  = string
    port  = string
    priority = number
  }))

  default = [{
    name = "prometheus"
    port = "9090"
    priority = 500
  }, 
  {
    name = "grafana"
    port = "3000"
    priority = 501
  },
  {
    name = "myapp"
    port = "8080"
    priority = 502
  },
  {
    name = "pushgateway"
    port = "9091"
    priority = 503
  },
  {
    name = "alertmanager"
    port = "9093"
    priority = 504
  }]
}

variable "cluster_subnet_name" {
  type = string
  default = "aks-subnet"
}