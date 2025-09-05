resource "grafana_dashboard" "my_dashboard" {
  config_json = file("${path.module}/mydashboard.json")
}