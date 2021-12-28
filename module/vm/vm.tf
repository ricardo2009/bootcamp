terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
    name     = "myResourceGroup"
    location = var.location

    tags = {
        environment = "bootcamp"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "this" {
     name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.this.name
    tags = {
        environment = "bootcamp"
    }
}


# Create subnet
resource "azurerm_subnet" "this" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes       = ["10.0.1.0/24"]
}


# Create public IPs
resource "azurerm_public_ip" "this" {
    name                         = "myPublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.this.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "bootcamp"
    }
}

variable "location" {
    default = "eastus2"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "this" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.this.name

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
        environment = "bootcamp"
    }
}


# Create network interface
resource "azurerm_network_interface" "this" {
    name                      = "myNIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.this.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.this.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.this.id
    }

    tags = {
        environment = "bootcamp"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "this" {
    network_interface_id      = azurerm_network_interface.this.id
    network_security_group_id = azurerm_network_security_group.this.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.this.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "this" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.this.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "this_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.this_ssh.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = var.location
    resource_group_name   = azurerm_resource_group.this.name
    network_interface_ids = [azurerm_network_interface.this.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.this_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.this.primary_blob_endpoint
    }

    tags = {
        environment = "bootcamp"
    }
}