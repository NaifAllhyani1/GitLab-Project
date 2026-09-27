resource "azurerm_resource_group" "gitlab" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "gitlab" {
  name                = "vnet-gitlab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gitlab.location
  resource_group_name = azurerm_resource_group.gitlab.name
}

resource "azurerm_subnet" "gitlab" {
  name                 = "subnet-gitlab"
  resource_group_name  = azurerm_resource_group.gitlab.name
  virtual_network_name = azurerm_virtual_network.gitlab.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "gitlab" {
  name                = "nsg-gitlab"
  location            = azurerm_resource_group.gitlab.location
  resource_group_name = azurerm_resource_group.gitlab.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-GitLab-SSH"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2222"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_public_ip" "gitlab" {
  name                = "pip-gitlab"
  location            = azurerm_resource_group.gitlab.location
  resource_group_name = azurerm_resource_group.gitlab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "gitlab" {
  name                = "nic-gitlab"
  location            = azurerm_resource_group.gitlab.location
  resource_group_name = azurerm_resource_group.gitlab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.gitlab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gitlab.id
  }
}

resource "azurerm_network_interface_security_group_association" "gitlab" {
  network_interface_id      = azurerm_network_interface.gitlab.id
  network_security_group_id = azurerm_network_security_group.gitlab.id
}

resource "azurerm_linux_virtual_machine" "gitlab" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.gitlab.name
  location            = azurerm_resource_group.gitlab.location
  size                = "Standard_D2as_v7"


  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.gitlab.id
  ]

  admin_ssh_key {
    username   = var.admin_username
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