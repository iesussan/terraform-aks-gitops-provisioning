variable "resource_group_name" {
  type = string
  description = "Resource Group Name"
}

variable "resource_group_location" {
  type = string
  description = "Resource Group Location"
  validation {
    condition = contains(["eastus", "westus2", "westeurope"], var.resource_group_location)
    error_message = "Invalid location"
  }
}

variable "resource_group_tags" {
  type = map(any)
  default = {}
  description = "Resource Group tags"
}