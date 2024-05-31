variable "virtual_network_exists" {
  description = "Flag to determine if the virtual network should be created"
  type        = bool
}
variable "azure_bastion_exists" {
  description = "Flag to determine if the Azure Bastion should be created"
  type        = bool
}
variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

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

variable "virtual_network_address_space" {
  description = "The address space that is used the virtual network"
  type        = list(string)
  validation {
        condition     = alltrue([
                      for adress_space in var.virtual_network_address_space :
                      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", adress_space))
                    ])
    error_message = "The address space must contain exactly one address prefix in CIDR notation."
  }
}

variable "virtual_network_subnets" {
  description = "A list of subnets"
  type        = list(object({
    name           = string
    address_prefix = string
    service_endpoints = list(string)
  }))
  validation {
    condition     = alltrue([
                      for subnet in var.virtual_network_subnets :
                      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", subnet.address_prefix))
                    ])
    error_message = "Each subnet address prefix must be in CIDR notation."
  }
  }

variable "tags" {
  default     = {}
  description = "Any tags that should be present on the Virtual Network resources"
  type        = map(string)
}


# variable "resources" {}
# variable "aksv_subnet_endpoints" {}
# variable "vnet_id" {}
# variable "criticality" {}
# variable "custom_nsg_rules" {}



# locals {

#   tags = merge(var.resources.tagsDefault, var.tags)
#   vnet_id = var.vnet_id
#   apgwr = { 
#     "Allow_Apgw_To_System" = {
#       priority = 103
#       direction = "Inbound"
#       source_address_prefix        =  var.resources.apgw_subnet
#       destination_address_prefixes = [var.resources.aks_subnet]
#       access                       = "Allow"
#       protocol                     = "TCP"
#       destination_port_range       = "*"
#     }
#   }

#   ips_rules_single_node_pool = {
#     "Allow_System_To_System" = {
#      priority = 110
#      direction = "Inbound"
#      source_address_prefix        = var.resources.aks_subnet
#      destination_address_prefixes = [var.resources.aks_subnet]
#      access                       = "Allow"
#      protocol                     = "*"
#      destination_port_range       = "*"
#     }, 
#     "Allow_LB_to_systems" = {
#      priority = 150
#      direction = "Inbound"
#      source_address_prefix        = "AzureLoadBalancer"
#      destination_address_prefixes = [var.resources.aks_subnet]
#      access                       = "Allow"
#      protocol                     = "*"
#      destination_port_range       = "*"
#     },
#     "Deny_Any_To_System" = {
#      priority = 300
#      direction = "Inbound"
#      source_address_prefix        = "*"
#      destination_address_prefixes = [var.resources.aks_subnet]
#      access                       = "Deny"
#      protocol                     = "*"
#      destination_port_range       = "*"
#     }
#   }

#   nsg_rules = merge(var.custom_nsg_rules,local.ips_rules_single_node_pool)
#   my_all_nsg_rules = var.resources.apgw_enabled ? merge(local.apgwr,local.nsg_rules): local.nsg_rules 

# }
