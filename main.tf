terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tf-az-rg" {
  name     = "tf-az-resources"
  location = "West Europe"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "tf-az-vnet" {
  name                = "tf-az-network"
  resource_group_name = azurerm_resource_group.tf-az-rg.name
  location            = azurerm_resource_group.tf-az-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "tf-az-subnet" {
  name                 = "tf-az-subnet"
  resource_group_name  = azurerm_resource_group.tf-az-rg.name
  virtual_network_name = azurerm_virtual_network.tf-az-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "tf-az-nsg" {
  name                = "tf-az-nsg"
  location            = azurerm_resource_group.tf-az-rg.location
  resource_group_name = azurerm_resource_group.tf-az-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "tf-az-nsg-rule" {
  name                        = "tf-az-nsg-rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-az-rg.name
  network_security_group_name = azurerm_network_security_group.tf-az-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "tf-az-subnet-nsg" {
  subnet_id                 = azurerm_subnet.tf-az-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-az-nsg.id
}

resource "azurerm_public_ip" "tf-az-pip" {
  name                = "tf-az-pip"
  location            = azurerm_resource_group.tf-az-rg.location
  resource_group_name = azurerm_resource_group.tf-az-rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "tf-az-nic" {
  name                = "tf-az-nic"
  location            = azurerm_resource_group.tf-az-rg.location
  resource_group_name = azurerm_resource_group.tf-az-rg.name

  ip_configuration {
    name                          = "tf-az-nic-ip"
    subnet_id                     = azurerm_subnet.tf-az-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-az-pip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "tf-az-vm" {
  name                = "tf-az-vm"
  resource_group_name = azurerm_resource_group.tf-az-rg.name
  location            = azurerm_resource_group.tf-az-rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tf-az-nic.id
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/tf-az-keyssh.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name = "tf-az-vm"
  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/tf-az-keyssh.pub")
  # }

  tags = {
    environment = "dev"
  }
}

# data "azurerm_public_ip" "tf-az-pip" {
#   name                = azurerm_public_ip.tf-az-pip.name
#   resource_group_name = azurerm_resource_group.tf-az-rg.name
# }

# output "public_ip_address" {
#   value = data.azurerm_public_ip.tf-az-pip.ip_address
# }