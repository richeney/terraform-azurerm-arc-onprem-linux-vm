// Debugging

output "cloud_init" {
  value = data.template_cloudinit_config.multipart.rendered
}

output "azcmagent_download" {
  value = local.azcmagent_download
}

output "azcmagent_connect" {
  value = local.azcmagent_connect
}

output "arc" {
  value = var.arc
}

output "arc_tags_string" {
  value = local.arc_tags_string
}
