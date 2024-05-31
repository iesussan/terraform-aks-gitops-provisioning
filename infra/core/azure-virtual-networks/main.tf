resource "azurerm_virtual_network" "network" {
  count               = var.virtual_network_exists ? 0 : 1  # No crear si la red ya existe
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
  tags = var.tags
}

data "azurerm_virtual_network" "existing_network" {
  count = var.virtual_network_exists ? 1 : 0  # Obtener datos solo si la red existe
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  # Filtra la subnet específica basada en la condición de que azure_bastion_exists sea true
  for_each = {
    for subnet in var.virtual_network_subnets :
    subnet.name => subnet if !(subnet.name == "AzureBastionSubnet" && var.azure_bastion_exists)
  }
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [each.value.address_prefix]
  virtual_network_name = var.virtual_network_exists ? data.azurerm_virtual_network.existing_network[0].name : azurerm_virtual_network.network[0].name
  service_endpoints    = each.value.service_endpoints
}

