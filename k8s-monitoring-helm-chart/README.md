# Usage

To deploy this lab locally, you will use Kind running on Docker or Podman. Be aware that local Kubernetes clusters require a lot of CPU and memory resources and might slow down your machine significantly. If you are able to, setting up an AWS EKS cluster or Azure AKS are good alternatives, in which case, you can skip the next step.

## Managing the Kind cluster

[Reference doc for Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

1. Install [Docker](https://docs.docker.com/engine/install/) or [Podman](https://podman.io/docs/installation)
1. Install the [Helm CLI](https://helm.sh/docs/intro/install/)
1. Install [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
1. Run `kind create cluster --config kind-config.yaml`
1. Connect to your cluster with `kubectl cluster-info --context kind-kind`
1. Verify your cluster setup with `kubectl get ns` to list the default namespaces

Kind clusters can survive restarts but usually don't do it on their own. You can check the status of your cluster by running `docker ps` and you should see something like this:

```bash
12565f0a18c4  docker.io/kindest/node@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f              2 months ago  Up 2 seconds                             kind-worker
38113169979f  docker.io/kindest/node@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f              2 months ago  Up 2 seconds                             kind-worker2
e270cdb86b65  docker.io/kindest/node@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f              2 months ago  Up 2 seconds  127.0.0.1:57725->6443/tcp  kind-control-plane
```

where the `kind` prefix  of the container name is the name of your cluster.

You can resume your cluster by running:

`docker start $(docker ps -q -a --filter "name=kind")`

Or stop it by running

`docker stop $(docker ps -q -a --filter "name=kind")`

## Preparing the chart values

In the grafana-monitoring.yaml, update the destinations with your values. Examples:

GRAFANA_CLOUD_METRICS_URL
GRAFANA_CLOUD_TRACES_URL
GRAFANA_CLOUD_LOGS_USERNAME
...

The default deployment includes everything. If you don't have enough resources to deploy all the sub-charts, you can turn off features by setting `enabled` to `false` under the `alloy-*` objects, and the corresponding features.

## Deploying the Grafana monitoring chart

```bash
helm repo add grafana https://grafana.github.io/helm-charts &&
  helm repo update &&
  helm upgrade --install --version ^2 --atomic --timeout 300s grafana-k8s-monitoring grafana/k8s-monitoring \
    --namespace "grafana-monitoring" --create-namespace --values grafana-monitoring.yaml
```

Run `kubectl get pods -n grafana-monitoring -w` to watch the pods come up

## Useful Helm commands

Run `helm list -n grafana-monitoring` to see the deployed chart
Run `helm get manifest grafana-k8s-monitoring -n grafana-monitoring` to list all the deployed manifests
Run `helm get values grafana-k8s-monitoring -n grafana-monitoring` to see the deployed values file

## Updating the values after initial deployment

```bash
  helm upgrade --timeout 300s grafana-k8s-monitoring grafana/k8s-monitoring \
    --namespace "default" --values grafana-monitoring.yaml
```
