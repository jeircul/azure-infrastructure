variable "client_secret" {
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "terraformgroup" {
    name     = "ansibleTerraformRG"
    location = "norwayeast"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Virtual network
resource "azurerm_virtual_network" "terraformnetwork" {
    name                = "virtualNetwork"
    address_space       = ["10.0.0.0/16"]
    location            = "norwayeast"
    resource_group_name = azurerm_resource_group.terraformgroup.name

    tags = {
        environment = "Terraform Deployment"
    }
}

# Subnet
resource "azurerm_subnet" "terraformsubnet" {
    name                 = "subnet"
    resource_group_name  = azurerm_resource_group.terraformgroup.name
    virtual_network_name = azurerm_virtual_network.terraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "terraformpublicip" {
    name                         = "publicIP"
    location                     = "norwayeast"
    resource_group_name          = azurerm_resource_group.terraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Network security group
resource "azurerm_network_security_group" "terraformnsg" {
    name                = "networkSecurityGroup"
    location            = "norwayeast"
    resource_group_name = azurerm_resource_group.terraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Deployment"
    }
}

# Network interface card
resource "azurerm_network_interface" "terraformnic" {
    name                        = "terraform-vm-nic"
    location                    = "norwayeast"
    resource_group_name         = azurerm_resource_group.terraformgroup.name

    ip_configuration {
        name                          = "nicConfiguration"
        subnet_id                     = azurerm_subnet.terraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.terraformpublicip.id
    }

    tags = {
        environment = "Terraform Deployment"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.terraformnic.id
    network_security_group_id = azurerm_network_security_group.terraformnsg.id
}

# Storage account
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.terraformgroup.name
    }

    byte_length = 8
}
resource "azurerm_storage_account" "storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.terraformgroup.name
    location                    = "norwayeast"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Virtual machine
resource "azurerm_linux_virtual_machine" "terraformvm" {
    name                  = "terraform-vm"
    location              = "norwayeast"
    resource_group_name   = azurerm_resource_group.terraformgroup.name
    network_interface_ids = [azurerm_network_interface.terraformnic.id]
    size                  = "Standard_B2s"

    os_disk {
        name              = "osDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "terraform-vm"
    admin_username = "sysAdmin"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "sysAdmin"
        public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKN4ntF9YHFsDwbH8ISb/OcTRacT5os8CUNy/Mgah0mJtUShhV+sHZRl1nSCn/c7yU4iOLoN64U3Ejskk7a/KjMg5QH8xUbmol5Gj5MyODaNN58VW3PD2e1doeCEwO68d/C2P1Y0kiTNZpcQdnvgAcIgXctdP/8yvG2E3N162Ahwl/KKERgSyVEbewm0vs5s4lyogseFU+taXQKVl1gsXS6oVZw0qqTSHkxFhv3gAdu7izBtA4AussjFTK+aKDMPBCeNVzmGZGXmSmuJjf32t17eE9BPqsmIKdJNCBEcnGODPPf+zOTVK6DRlMAwI70dnfyOELzO1c7H2+cpwVPyMLHGjF+ObqcNy+dqQug0J1ap/QteSo6jPRk1wWwcwFZzRFygGDNU83CaJX9ZZDC4EBcArcuj1xoI2oFSKUxn6uXbfzmfhZ9OqCxwk1aCuJfDqJoot1MLIyQ2azvD7VBAML1OEW3oEt4V5lDFrbZ1mdmKt4qI37/tp1cLFFF/WR6EoC/gTczShjaD8OQlE4kTl7ZhP1193MF9KbFX2WtH8/LQ0FinrZi8gCtiqx+GfN4Et2EMo4e7fsVAlXdp6zeZTDqrJiOxy5O9NcetZmKz0+tcTAG59uwzvgzGW49UrrpE8Tx4OznKIbRs2JrazdEYXqV8W8UsL1YpjI67WdxN4vjQ== morten@morten-laptop"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Deployment"
    }
}
