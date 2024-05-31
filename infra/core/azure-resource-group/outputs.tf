output "name" {
    description = "Resource Group Name"
    value = azurerm_resource_group.rg.name
}

output "location" {
    description = "Resource Group Location"
    value = azurerm_resource_group.rg.location
}

output "id" {
    description = "Resource Group Id"
    value = azurerm_resource_group.rg.id
}

