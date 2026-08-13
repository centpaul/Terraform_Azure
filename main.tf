terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------------------------------------------
# Resource Group
# --------------------------------------------------

resource "azurerm_resource_group" "vm_resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# --------------------------------------------------
# Virtual Network
# --------------------------------------------------

resource "azurerm_virtual_network" "vm_virtual_network" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_resource_group.location
  resource_group_name = azurerm_resource_group.vm_resource_group.name
}

# --------------------------------------------------
# Subnet
# --------------------------------------------------

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.vm_resource_group.name
  virtual_network_name = azurerm_virtual_network.vm_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# --------------------------------------------------
# Public IP
# --------------------------------------------------

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.vm_name}-public-ip"
  location            = azurerm_resource_group.vm_resource_group.location
  resource_group_name = azurerm_resource_group.vm_resource_group.name

  allocation_method = "Static"
  sku               = "Standard"
}

# --------------------------------------------------
# Network Security Group
# --------------------------------------------------

resource "azurerm_network_security_group" "vm_security_group" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.vm_resource_group.location
  resource_group_name = azurerm_resource_group.vm_resource_group.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address
    destination_address_prefix = "*"
  }
}

# --------------------------------------------------
# Network Interface
# --------------------------------------------------

resource "azurerm_network_interface" "vm_network_interface" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.vm_resource_group.location
  resource_group_name = azurerm_resource_group.vm_resource_group.name

  ip_configuration {
    name                          = "primary-ip-configuration"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# --------------------------------------------------
# Associate Network Security Group with NIC
# --------------------------------------------------

resource "azurerm_network_interface_security_group_association" "vm_security_group_association" {
  network_interface_id      = azurerm_network_interface.vm_network_interface.id
  network_security_group_id = azurerm_network_security_group.vm_security_group.id
}

# --------------------------------------------------
# Linux Virtual Machine
# --------------------------------------------------

resource "azurerm_linux_virtual_machine" "application_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.vm_resource_group.name
  location            = azurerm_resource_group.vm_resource_group.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.vm_network_interface.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    name                 = "${var.vm_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}