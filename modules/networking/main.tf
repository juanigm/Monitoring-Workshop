resource "azurerm_network_security_group" "vnet-sg" {
  name                = var.sg-name
  location            = var.location
  resource_group_name = var.rg-name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name
  location            = var.location
  resource_group_name = var.rg-name
  address_space       = var.CIDR

  dynamic "subnet" {
    for_each = var.subnets
    content {
      name           = subnet.value.name
      address_prefix = subnet.value.address_prefix
      security_group = azurerm_network_security_group.vnet-sg.id
    }

  }

  tags = {
    environment = "Production"
  }
}