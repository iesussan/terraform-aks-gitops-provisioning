output "azure_virtual_network_id" {
  value = var.virtual_network_exists ? data.azurerm_virtual_network.existing_network[0].id : azurerm_virtual_network.network[0].id
}

output "azure_virtual_network_name" {
  value = var.virtual_network_exists ? data.azurerm_virtual_network.existing_network[0].name : azurerm_virtual_network.network[0].name
}

output "subnet_info" {
  value = [for subnet in azurerm_subnet.subnet : {
    id = subnet.id,
    name = subnet.name
  }]
}

output "subnet_ids" {
  description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}

output "azurerm_virtual_network_name" {
  value = var.virtual_network_exists ? data.azurerm_virtual_network.existing_network[0].name : azurerm_virtual_network.network[0].name
}
