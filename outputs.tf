output "public_ip" {
  value = azurerm_public_ip.tf-az-pip.ip_address
}