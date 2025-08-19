// Create a cloud provider
provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.cloud_access_policy_token
}

resource "grafana_cloud_org_member" "some_member" {
   org = var.org_slug
   role = "basic_none"
   user = "mrethers"
   receive_billing_emails = false
}