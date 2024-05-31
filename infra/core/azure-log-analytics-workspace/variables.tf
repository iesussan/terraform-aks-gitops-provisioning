variable "log_analytics_workspace_name" {
    description =  "Azure log analytics workspace name"
    type = string
}
variable "location" {
    description = "Azure log analytics workspace location"
    type = string 
}
variable "resource_group_name" {
    description = "Azure log analytics workspace resource group name"
    type = string
}
variable "log_analytics_workspace_sku" {
    description = "Azure log analytics workspace sku"
    type = string
    default = "PerGB2018"
}
variable "log_analytics_workspace_retention_in_days" {
    description = "Azure log analytics workspace retention in days"
    type = string
    default = "30"
}