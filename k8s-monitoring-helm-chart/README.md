# Usage

## Running the kind cluster

1. `kind create cluster --config kind-config.yaml`
1. `kubectl apply -f metric-server.yaml`

## Deploying the Grafana monitoring chart

```bash
helm repo add grafana https://grafana.github.io/helm-charts &&
  helm repo update &&
  helm upgrade --install --version ^2 --atomic --timeout 300s grafana-k8s-monitoring grafana/k8s-monitoring \
    --namespace "default" --create-namespace --values grafana-monitoring.yaml
```
