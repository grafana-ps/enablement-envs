variable "cloud_access_policy_token" {
  description = "Bootstrap token from the org portal under Security -> Access Policy. See https://grafana.com/docs/grafana-cloud/developer-resources/infrastructure-as-code/terraform/terraform-cloud-stack/"
}

variable "org_slug" {
  description = "The organization slug"
}