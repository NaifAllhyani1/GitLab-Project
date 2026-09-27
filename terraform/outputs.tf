output "public_ip_address" {
  description = "Public IP address of the GitLab VM"
  value       = azurerm_public_ip.gitlab.ip_address
}

output "vm_name" {
  description = "Name of the GitLab VM"
  value       = azurerm_linux_virtual_machine.gitlab.name
}