resource "google_project_service" "service" {
  for_each = local.services
  service  = each.value
}
