variable "log_analytics_workspace_id" {
  type = string
}

variable "kubernetes_version" {
  type = string
}
variable "kubernetes_service_name" {
 description = "The name of the Kubernetes Service"
 type = string
}
variable "location" {
  description = "The location/region where the virtual network is created"
  type        = string
  validation {
    condition     = can(regex("^(eastus|eastus2|centralus)$", var.location))
    error_message = "The location must be a valid Azure location."
  }
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network"
  type        = string
}
variable "resource_group_id" {
  description = "The id of the resource group in which to create the virtual network"
  type        = string
}
variable "application_code" {
  description = "The name of the application code"
  type        = string
}
variable "sku_tier" {
  description = "The sku tier of the Kubernetes Service"
  type        = string
  default     = "Standard"
  validation {
    condition     = can(regex("^(Free|Standard|Paid)$", var.sku_tier))
    error_message = "The sku tier must be Free or Paid."
  }
}
variable "azure_policy_enabled" {
  description = "Enable Azure Policy for the Kubernetes Service"
  type        = bool
  default     = true
}
variable "http_application_routing_enabled" {
  description = "Enable HTTP application routing for the Kubernetes Service"
  type        = bool
  default     = false
}

variable "private_cluster_enabled" {
  description = "Enable private cluster for the Kubernetes Service"
  type = bool
}

variable "kubernetes_apiserver_subnet_id" {
  description = "The subnet id of the kubernetes apiserver"
  type        = string
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, and stable."
  default     = "stable"
  type        = string

  validation {
    condition = contains( ["patch", "rapid", "stable"], var.automatic_channel_upgrade)
    error_message = "The upgrade mode is invalid."
  }
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "outbound_type" {
  description = ""
  type = string
  default = "loadBalancer"
}
variable "image_cleaner_enabled" {
  description = "Enable image cleaner for the Kubernetes Service"
  type        = bool
  default     = true
}
variable "image_cleaner_interval_hours" {
  description = "The interval hours of the image cleaner"
  type        = number
  default     = 48
}

#################################### system node pool definitions ####################################
variable "systemnode_poolname" {
  description = "The name of the system node pool"
  type        = string
}
variable "systemnodes_zones" {
  description = "The number of system nodes"
  type        = list(number)
  validation {
    condition     = alltrue([for zone in var.systemnodes_zones : contains([1, 2, 3], zone)])
    error_message = "Each zone number must be 1, 2, or 3."
  }
}
variable "systemnode_count" {
  description = "The number of system nodes"
  type        = number
  validation {
    condition     = can(regex("^(1|2|3)$", var.systemnode_count))
    error_message = "The number of system nodes must be 1, 2 or 3."
  }
}
variable "systemnode_vm_size" {
  description = "The size of the system nodes"
  type        = string
  validation {
    condition = can(regex("^(Standard_D2a_v4|Standard_D2s_v3|Standard_D4s_v3|Standard_D8s_v3|Standard_D16s_v3|Standard_D32s_v3|Standard_D64s_v3)$", var.systemnode_vm_size))
    error_message = "The size of the system nodes must be Standard_D2a_v4, Standard_D2s_v3, Standard_D4s_v3, Standard_D8s_v3, Standard_D16s_v3, Standard_D32s_v3 or Standard_D64s_v3."
  }
}
variable "systemnode_subnet_id" {
  description = "The subnet id of the system nodes"
}
variable "systemnode_max_pods" {
  description = "The maximum number of pods that can run on a system node"
  type        = number
  default = 50
}
variable "systemnode_max_count" {
  description = "The maximum number of system nodes"
  type        = number
  default = 10
}
variable "systemnode_min_count" {
  description = "The minimum number of system nodes"
  type        = number
  default = 2
}
variable "systemnode_enable_auto_scaling" {
  description = "Enable auto scaling for the system node pool"
  type        = bool
  default = true
}
variable "systemnode_labels" {
  description = "The labels of the system node pool"
  type        = map(string)
  default = {
  }
}
variable "systemnode_only_critical_addons_enabled" {
  description = "The taints of the system node pool"
  type        = bool
  default     = true
}
##########################################################################################################################################
variable "usernode_subnet_id" {
  description = "The subnet id of the user nodes"
}

variable "usernode_poolname" {
  description = "The name of the system node pool"
  type        = string
}

variable "usernode_zones" {
  type          = list(number)
  description   = "List of availability zones for the user node pool"
  default       = [1, 2, 3]
  validation {
    condition     = alltrue([for zone in var.usernode_zones : contains([1, 2, 3], zone)])
    error_message = "Each zone in usernode_zones must be one of: 1, 2, 3."
  }
}
variable "usernode_min_count" {
  description = "The number of system nodes"
  type        = number
}
variable "usernode_max_count" {
  description = "The number of system nodes"
  type        = number
}
variable "usernode_vm_size" {
  description = "The size of the system nodes"
  type        = string
  validation {
    condition = can(regex("^(Standard_D2a_v4|Standard_D2s_v3|Standard_D4s_v3|Standard_D8s_v3|Standard_D16s_v3|Standard_D32s_v3|Standard_D64s_v3)$", var.usernode_vm_size))
    error_message = "The size of the system nodes must be Standard_D2a_v4, Standard_D2s_v3, Standard_D4s_v3, Standard_D8s_v3, Standard_D16s_v3, Standard_D32s_v3 or Standard_D64s_v3."
  }
}
variable "identity" {
  description = "The identity of the Kubernetes Service"
  default = "SystemAssigned"
  validation {
    condition     = can(regex("^(SystemAssigned|None)$", var.identity))
    error_message = "The identity must be SystemAssigned or None."
  }
}
variable "admin_group_members" {
  description = "The members of the admin group"
}
variable "network_plugin" {
  description = "The network plugin of the Kubernetes Service"
  default = "azure"
  validation {
    condition     = can(regex("^(azure|kubenet)$", var.network_plugin))
    error_message = "The network plugin must be azure or kubenet."
  }
}
variable "load_balancer_sku" {
  description = "The load balancer sku of the Kubernetes Service"
  default = "standard"
  validation {
    condition     = can(regex("^(standard|basic)$", var.load_balancer_sku))
    error_message = "The load balancer sku must be standard or basic."
  }
}
# variable "resource_provider" {
#   description = "The resource provider of the Kubernetes Service"
#   type = map(string)
# }

variable "kubernetes_configuration" {
  type = object({
    namespaces = list(object({
      name = string
    }))
  })
}

variable "azure_container_registry_id" {
  description = "The Azure Container Registry ID"
  type = string
}

variable "gitops_flux_configuration" {
  description = "The GitOps Flux Configuration"
  type = object({
    extension_type = string
    extension_name = string  # Agrega esta línea
    git_repository_url = string
  })
}
