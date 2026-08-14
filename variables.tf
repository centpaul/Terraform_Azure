variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "terraform-vm-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "Name of the Azure Linux VM"
  type        = string
  default     = "terraform-azure-vm"
}

variable "vm_size" {
  description = "Azure VM instance size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key used to access the VM"
  type        = string
  sensitive   = true
}


variable "ssh_source_address" {
  description = "Public IPv4 address or CIDR allowed to connect to the VM over SSH"
  type        = string

  validation {
    condition     = var.ssh_source_address != "0.0.0.0/0"
    error_message = "SSH access must not be open to the entire internet."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
}