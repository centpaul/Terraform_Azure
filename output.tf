output "resource_group_name" {
  description = "Azure Resource Group containing the VM"
  value       = azurerm_resource_group.vm_resource_group.name
}

output "vm_name" {
  description = "Name of the Azure VM"
  value       = azurerm_linux_virtual_machine.application_vm.name
}

output "vm_public_ip" {
  description = "Public IP address of the Azure VM"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the Azure VM"
  value       = azurerm_network_interface.vm_network_interface.private_ip_address
}

output "ssh_command" {
  description = "Command used to connect to the Azure VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm_public_ip.ip_address}"
}