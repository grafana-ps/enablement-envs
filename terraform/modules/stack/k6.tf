resource "grafana_k6_installation" "k6_installation" {

  count = var.k6 ? 1 : 0
  
  cloud_access_policy_token = var.root_token
  stack_id                  = grafana_cloud_stack.this.id
  grafana_sa_token          = grafana_cloud_stack_service_account_token.cloud_sa.key
  grafana_user              = "admin"
}

output "k6_installation" {

    value = var.k6 ? grafana_k6_installation.k6_installation[0] : null
    sensitive = true
}