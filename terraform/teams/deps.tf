terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "3.25.2"
    }
    aws = {
      source = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}