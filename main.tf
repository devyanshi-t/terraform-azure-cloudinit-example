
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = "packages: ['httpie']"
  }
}

resource "azurerm_resource_group" "cloudinit" {
  name     = "cloudinit-resources"
  location = var.location
}

resource "azurerm_virtual_network" "cloudinit" {
  name                = "cloudinit-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name
}

resource "azurerm_subnet" "cloudinit" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.cloudinit.name
  virtual_network_name = azurerm_virtual_network.cloudinit.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "cloudinit" {
  name                = "cloudinit-pip"
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "cloudinit" {
  name                = "cloudinit-sg"
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name

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
}

resource "azurerm_network_interface" "cloudinit" {
  name                = "cloudinit-nic"
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name

  ip_configuration {
    name                          = "cloudinit-nic-config"
    subnet_id                     = azurerm_subnet.cloudinit.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cloudinit.id
  }
}

resource "azurerm_network_interface_security_group_association" "cloudinit" {
  network_interface_id      = azurerm_network_interface.cloudinit.id
  network_security_group_id = azurerm_network_security_group.cloudinit.id
}

resource "azurerm_linux_virtual_machine" "cloudinit" {
  name                = "cloudinit-machine"
  resource_group_name = azurerm_resource_group.cloudinit.name
  location            = azurerm_resource_group.cloudinit.location
  size                = "Standard_B1s"
  admin_username      = "cloudinit"
  admin_password      = "HKKRoD24XLBzxdD"


  # This is where we pass our cloud-init.
  custom_data = data.template_cloudinit_config.config.rendered

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.cloudinit.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

