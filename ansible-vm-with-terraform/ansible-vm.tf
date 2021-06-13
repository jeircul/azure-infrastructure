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
    name     = var.resource_group
    location = var.location

    tags = {
        environment = "Terraform Deployment"
    }
}

# Virtual network
resource "azurerm_virtual_network" "terraformnetwork" {
    name                = join("", [var.project_name,"-vnet"])
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.terraformgroup.name

    tags = {
        environment = "Terraform Deployment"
    }
}

# Subnet
resource "azurerm_subnet" "terraformsubnet" {
    name                 = join("", [var.project_name,"subnet"])
    resource_group_name  = azurerm_resource_group.terraformgroup.name
    virtual_network_name = azurerm_virtual_network.terraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "terraformpublicip" {
    name                         = join("", [var.project_name,"publicIP"])
    location                     = var.location
    resource_group_name          = azurerm_resource_group.terraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Network security group
resource "azurerm_network_security_group" "terraformnsg" {
    name                = join("", [var.project_name, "NSG"])
    location            = var.location
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
    name                        = join("", [var.project_name, "nic"])
    location                    = var.location
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

# Random ID for Storage account
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.terraformgroup.name
    }
    byte_length = 8
}

# Storage account
resource "azurerm_storage_account" "storageaccount" {
    name                        = "storage${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.terraformgroup.name
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Virtual machine
resource "azurerm_linux_virtual_machine" "terraformvm" {
    name                  = join("", [var.project_name, "-vm"])
    location              = var.location
    resource_group_name   = azurerm_resource_group.terraformgroup.name
    network_interface_ids = [azurerm_network_interface.terraformnic.id]
    size                  = "Standard_B2s"

    os_disk {
        name              = join("", [var.project_name, "osDisk"])
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = join("", [var.project_name, "-vm"])
    admin_username = var.user_name
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.user_name
        public_key     = var.public_key
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Deployment"
    }
}
