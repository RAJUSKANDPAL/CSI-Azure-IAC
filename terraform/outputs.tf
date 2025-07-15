output "public_ip_addresses" {
  value       = azurerm_public_ip.public_ip[*].ip_address
  description = "Public IPs of all VMs"
}

output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_public_ip.ip_address
  description = "Public IP of the Load Balancer"
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Local path to the generated private SSH key"
}
