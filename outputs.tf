output "public_ip" {
  value = azurerm_linux_virtual_machine.cloudinit.public_ip_address
}