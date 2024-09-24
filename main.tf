resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location
  name     = "devops_${var.resource_group_name_prefix}"
}

resource "azurerm_virtual_network" "devops_network" {
  name                = "devops-network"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.resource_group_location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "production"
    department  = "IT"
  }
}