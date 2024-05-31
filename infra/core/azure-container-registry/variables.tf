variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network"
  type        = string
}

variable "location" {
  description = "The location/region where the virtual network is created"
  type        = string
  validation {
    condition     = can(regex("^(eastus|eastus2|centralus)$", var.location))
    error_message = "The location must be a valid Azure location."
  }
}

variable "acr_sku" {
  description = "The sku name of the acr"
  type = string
  validation {
    condition     = can(regex("^(Basic|Standard|Premium)$", var.acr_sku))
    error_message = "The sku name of the acr must be Basic, Standard or Premium."  
  }  
}

variable "admin_enabled" {
  description = "Enable admin user for the acr"
  type = bool
  default = true
}

variable "application_code" {
  description = "The name of the application code"
  type        = string
}

variable "georeplication_locations" {
  description = "Una lista de ubicaciones para la georeplicación y configuraciones de redundancia de zona."
  type = list(object({
    location               = string
    zone_redundancy_enabled = bool
  }))
  default = []
  }

variable "container_registry_name" {
  description = "The name of the container registry"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Enable public network access for the acr"
  type = bool
  default = false
}

variable "permitted_cidr" {
  description = "A list of subnets"
  type        = list(object({
    name           = string
    address_prefix = string
  }))
  default     = []
  validation {
    condition     = alltrue([
                      for subnet in var.permitted_cidr :
                      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", subnet.address_prefix))
                    ])
    error_message = "Each subnet address prefix must be in CIDR notation."
  }
  }
