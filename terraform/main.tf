provider "azurerm" {
  features {}
  subscription_id = "bb97b408-9e37-419f-95a3-84c116ff99bd"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content              = tls_private_key.ssh_key.private_key_pem
  filename             = "${path.module}/tera_vm_key.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "azurerm_resource_group" "rg" {
  name     = "rajus-${var.environment}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "tera-${var.environment}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "tera-${var.environment}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "tera-${var.environment}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

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
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "public_ip" {
  count               = 2
  name                = "tera-${var.environment}-public-ip-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "tera-${var.environment}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "tera-${var.environment}-lb-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "load_balancer" {
  name                = "tera-${var.environment}-loadbalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  name            = "tera-prod-backend-pool"
  loadbalancer_id = azurerm_lb.load_balancer.id
}

resource "azurerm_lb_probe" "http_probe" {
  name                = "http-health-probe"
  loadbalancer_id     = azurerm_lb.load_balancer.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-lb-rule"
  loadbalancer_id                = azurerm_lb.load_balancer.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}

resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "tera-${var.environment}-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = "rajus"
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    name                 = "tera-${var.environment}-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "rajus"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  disable_password_authentication = true

  custom_data = base64encode(<<EOF
#!/bin/bash
apt update
apt install -y apache2
echo "Hello from tera-prod-vm-${count.index}" > /var/www/html/index.html
systemctl enable apache2
systemctl start apache2
EOF
  )
}

output "vm1_public_ip" {
  value = azurerm_public_ip.public_ip[0].ip_address
}

output "vm2_public_ip" {
  value = azurerm_public_ip.public_ip[1].ip_address
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}
