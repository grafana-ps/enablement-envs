resource "grafana_cloud_plugin_installation" "polystat_panel" {
  stack_slug = var.stack.slug                # Replace with your Grafana Cloud stack slug
  slug       = "grafana-polystat-panel"   # Plugin ID for the Polystat Panel
  version    = "2.1.15"                   # Use "latest" to always install the latest version
}