output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "public_ip_addresses" {
  value = {
    master = azurerm_public_ip.public_ip[0].ip_address
    worker = azurerm_public_ip.public_ip[1].ip_address
  }
}

output "vm_names" {
  value = azurerm_linux_virtual_machine.vm[*].name
}
