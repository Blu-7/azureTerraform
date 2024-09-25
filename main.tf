resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location                // Location of the resource group
  name     = "devops_${var.resource_group_name_prefix}" // Name of the resource group

  tags = {
    environment = "production"
    department  = "IT"
  }
}

// Create a virtual network
resource "azurerm_virtual_network" "devops_network" {
  name                = "devops_network"                           // Name of the virtual network
  resource_group_name = azurerm_resource_group.resource_group.name // This is the reference to the resource group created above
  location            = var.resource_group_location                // Same location as the resource group
  address_space       = ["10.0.0.0/16"]                            // IP address range for the virtual network

  tags = {
    environment = "production"
    department  = "IT"
  }
}

// Create a subnet
resource "azurerm_subnet" "devops_subnet" {
  name                 = "devops_subnet"                             // Name of the subnet
  resource_group_name  = azurerm_resource_group.resource_group.name  // This is the reference to the resource group created above
  virtual_network_name = azurerm_virtual_network.devops_network.name // This is the reference to the virtual network created above
  address_prefixes     = ["10.0.1.0/24"]
}

// Create a network security group
resource "azurerm_network_security_group" "security_group" {
  name                = "security_group"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.resource_group.name

  tags = {
    environment = "Production"
    department  = "IT"
  }
}

// Create a security rule to allow inbound traffic
resource "azurerm_network_security_rule" "security_rule_outbound" {
  name                        = "security_rule_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

// Create a security rule to allow inbound traffic
resource "azurerm_network_security_rule" "security_rule_inbound" {
  name                        = "security_rule_inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

// Associate the network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "security_group_association" {
  subnet_id                 = azurerm_subnet.devops_subnet.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

// Create a public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.machine_prefix}-public_ip-${var.machine_name[count.index]}"
  count               = var.vm_count
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label = count.index == 0 ? "master-${var.dns_label_prefix}" : "worker-${var.dns_label_prefix}"

  tags = {
    environment = "Production"
    department  = "IT"
  }
}

// Create a network interface
resource "azurerm_network_interface" "network_interface" {
  name                = "${var.machine_prefix}-nic-${var.machine_name[count.index]}"
  count               = var.vm_count
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }

  tags = {
    environment = "Production"
    department  = "IT"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = 2
  name                = count.index == 0 ? "master" : "worker"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_DS1_v2"
  admin_username      = count.index == 0 ? "master" : "worker"
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.network_interface[count.index].id,
  ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}