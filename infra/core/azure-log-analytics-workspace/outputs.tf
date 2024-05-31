output "name" {
    description = "Log Analytics Workspace Name"
    value = azurerm_log_analytics_workspace.this.name
}

output "id" {
    description = "Log Analytics Workspace ID"
    value = azurerm_log_analytics_workspace.this.id
}