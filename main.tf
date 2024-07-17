# Azurerm provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.112.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#Creating resource group
resource "azurerm_resource_group" "zhaoyi-rg" {
  name     = "zhaoyi-resource"
  location = "East US"
  tags = {
    environment = "zhaoyi"
  }
}

#Creating Virtual Network
resource "azurerm_virtual_network" "zhaoyi-vn" {
  name                = "zhaoyi-network"
  resource_group_name = azurerm_resource_group.zhaoyi-rg.name
  location            = azurerm_resource_group.zhaoyi-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "developing"
  }
}

#Creating Subnet
resource "azurerm_subnet" "zhaoyi-sn" {
  name                 = "zhaoyi-subnet"
  resource_group_name  = azurerm_resource_group.zhaoyi-rg.name
  virtual_network_name = azurerm_virtual_network.zhaoyi-vn.name
  address_prefixes     = ["10.123.1.0/24"]

}

#Creating Security Group
resource "azurerm_network_security_group" "zhaoyi-sg" {
  name                = "zhaoyi-security-group"
  location            = azurerm_resource_group.zhaoyi-rg.location
  resource_group_name = azurerm_resource_group.zhaoyi-rg.name

  tags = {
    environment = "brandon"
  }
}

#Setting Security Rules
resource "azurerm_network_security_rule" "zhaoyi-sr" {
  name                        = "zhaoyi-security-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.zhaoyi-rg.name
  network_security_group_name = azurerm_network_security_group.zhaoyi-sg.name
}

#Creating Security Group Association
resource "azurerm_subnet_network_security_group_association" "zhaoyi-sga" {
  subnet_id                 = azurerm_subnet.zhaoyi-sn.id
  network_security_group_id = azurerm_network_security_group.zhaoyi-sg.id
}

#Setting up Public IP, take note public IP won't be created until it is attached to something. For example, a VM
resource "azurerm_public_ip" "zhaoyi-ip" {
  name                = "zhaoyi-ip"
  resource_group_name = azurerm_resource_group.zhaoyi-rg.name
  location            = azurerm_resource_group.zhaoyi-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "ipaddress"
  }
}

#Creating a network interface
resource "azurerm_network_interface" "zhaoyi-ni" {
  name                = "zhaoyi-network-interface"
  resource_group_name = azurerm_resource_group.zhaoyi-rg.name
  location            = azurerm_resource_group.zhaoyi-rg.location
  ip_configuration {
    name                          = "network-interface-ip-config"
    subnet_id                     = azurerm_subnet.zhaoyi-sn.id
    public_ip_address_id          = azurerm_public_ip.zhaoyi-ip.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
  }
}

#Creating a VM
resource "azurerm_linux_virtual_machine" "zhaoyi-vm" {
  name                  = "zhaoyi-virtual-machine"
  resource_group_name   = azurerm_resource_group.zhaoyi-rg.name
  location              = azurerm_resource_group.zhaoyi-rg.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.zhaoyi-ni.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/terrazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  #Custom Data to install Docker on VM, take note it should be after admin_ssh_key or admin_password
  custom_data = filebase64("customdata.tpl")
}