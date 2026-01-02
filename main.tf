terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}
provider "azurerm" {
  subscription_id = "50818730-e898-4bc4-bc35-d998af53d719"
  features {}
}

resource "azurerm_resource_group" "myResourceGroup" {
  name     = "myResourceGroup2"
  location = "West Europe"
}


resource "azurerm_virtual_network" "myVnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myResourceGroup2.location
  resource_group_name = azurerm_resource_group.myResourceGroup2.name
}

resource "azurerm_subnet" "mySubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myResourceGroup2.name
  virtual_network_name = azurerm_virtual_network.myVnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "myNicA" {
  name                = "myNicA"
  location            = azurerm_resource_group.myResourceGroup2.location
  resource_group_name = azurerm_resource_group.myResourceGroup2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mySubnetA.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

resource "azurerm_network_security_group" "myNsgA" {
  name                = "myNsg"
  location            = azurerm_resource_group.myResourceGroup2.location
  resource_group_name = azurerm_resource_group.myResourceGroup2.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "myNicANsgAssociation" {
  network_interface_id      = azurerm_network_interface.myNicA.id
  network_security_group_id = azurerm_network_security_group.myNsgA.id
}

resource "azurerm_linux_virtual_machine" "MyVm" {
  name                = "MyVm"
  resource_group_name = azurerm_resource_group.myResourceGroup2.name
  location            = azurerm_resource_group.myResourceGroup2.location
  size                = "Standard_B1s"
  admin_username      = "atul"
  network_interface_ids = [
    azurerm_network_interface.myNicA.id,
  ]

  admin_ssh_key {
    username   = "atul"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
}
}   
