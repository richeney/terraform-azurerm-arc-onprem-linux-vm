output "fqdn" {
  value = var.public_ip ? azurerm_public_ip.onprem["pip"].fqdn : null
}

output "public_ip_address" {
  value = var.public_ip ? azurerm_public_ip.onprem["pip"].ip_address : null
}

output "ssh_command" {
  value = var.public_ip ? "ssh ${var.admin_username}@${azurerm_public_ip.onprem["pip"].fqdn}" : null
}
