resource "grafana_cloud_access_policy" "sm_metrics_publish" {
  
  count = var.synthetics ? 1 : 0

  region = var.region
  name   = "metric-publisher-for-sm"
  scopes = ["metrics:write", "stacks:read", "logs:write", "traces:write"]
  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.this.id
  }
}

resource "grafana_cloud_access_policy_token" "sm_metrics_publish" {
  
  count = var.synthetics ? 1 : 0

  region           = var.region
  access_policy_id = grafana_cloud_access_policy.sm_metrics_publish[0].policy_id
  name             = "${var.slug}-sm-metric-publisher"
}

resource "grafana_synthetic_monitoring_installation" "sm_stack" {
  
  count = var.synthetics ? 1 : 0

  stack_id              = grafana_cloud_stack.this.id
  metrics_publisher_key = grafana_cloud_access_policy_token.sm_metrics_publish[0].token
}

output "sm_installation" {

    value = grafana_synthetic_monitoring_installation.sm_stack[0]
    sensitive = true
}