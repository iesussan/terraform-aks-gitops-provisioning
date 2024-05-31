module "azure-resource-group" {
  source = "./core/azure-resource-group"
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  resource_group_tags = var.resource_group_tags
  
}

module "azure-virtual-networks" {
  source = "./core/azure-virtual-networks"
  virtual_network_exists = var.virtual_network_exists
  azure_bastion_exists = var.azure_bastion_exists
  virtual_network_name = var.virtual_network_name
  resource_group_name = module.azure-resource-group.name
  location = module.azure-resource-group.location
  virtual_network_address_space = var.virtual_network_address_space
  virtual_network_subnets = var.virtual_network_subnets
}

locals {
  systemnode_subnet_id    = [for subnet in module.azure-virtual-networks.subnet_info : subnet.id if try(regex(".*systemnodes.*", subnet.name), null) != null][0]
  usernode_subnet_id      = [for subnet in module.azure-virtual-networks.subnet_info : subnet.id if try(regex(".*usernodes.*", subnet.name), null) != null][0]
  apiserver_subnet_id     = [for subnet in module.azure-virtual-networks.subnet_info : subnet.id if try(regex(".*apiservernodes.*", subnet.name), null) != null][0]
}

module "azure-container-registry" {
  source = "./core/azure-container-registry"
  container_registry_name = var.container_registry_name
  application_code = var.application_code
  resource_group_name = module.azure-resource-group.name
  location = module.azure-resource-group.location
  acr_sku = var.acr_sku
  permitted_cidr = var.virtual_network_subnets
}

module "azure-log-analytics-workspace" {
  source = "./core/azure-log-analytics-workspace"
  log_analytics_workspace_name = var.log_analytics_workspace_name
  location = module.azure-resource-group.location
  resource_group_name = module.azure-resource-group.name
  log_analytics_workspace_sku = var.log_analytics_workspace_sku
  log_analytics_workspace_retention_in_days = var.log_analytics_workspace_retention_in_days
  
}

module "azure-kubernetes-service" {
    source                          = "./core/azure-kubernetes-service"
    kubernetes_version              = var.kubernetes_version
    kubernetes_service_name         = var.kubernetes_service_name
    kubernetes_apiserver_subnet_id  = local.apiserver_subnet_id
    private_cluster_enabled         = var.private_cluster_enabled
    systemnode_poolname             = var.systemnode_poolname
    systemnodes_zones               = var.systemnodes_zones
    systemnode_count                = var.systemnode_count
    systemnode_vm_size              = var.systemnode_vm_size
    systemnode_subnet_id            = local.systemnode_subnet_id
    usernode_subnet_id              = local.usernode_subnet_id
    usernode_zones                  = var.usernode_zones
    usernode_min_count              = var.usernode_min_count
    usernode_vm_size                = var.usernode_vm_size
    usernode_poolname               = var.usernode_poolname
    usernode_max_count              = var.usernode_max_count
    identity                        = var.identity
    admin_group_members             = var.admin_group_members
    network_plugin                  = var.network_plugin
    load_balancer_sku               = var.load_balancer_sku
    resource_group_name             = module.azure-resource-group.name
    resource_group_id               = module.azure-resource-group.id
    location                        = module.azure-resource-group.location
    log_analytics_workspace_id      = module.azure-log-analytics-workspace.id
    application_code                = var.application_code
    kubernetes_configuration        = var.kubernetes_configuration
    azure_container_registry_id     = module.azure-container-registry.id
    gitops_flux_configuration       = var.gitops_flux_configuration
    depends_on = [ module.azure-container-registry, module.azure-log-analytics-workspace ]
}

# # Azure Chaos Studio Experiment for AKS VMSS
# data "external" "aks_vmss" {
#   program = ["${path.module}/../scripts/get_vmss_names.sh"]

#   query = {
#     resource_group   = module.azure-resource-group.name
#     aks_cluster_name = var.kubernetes_service_name
#   }
#   depends_on = [ module.azure-kubernetes-service ]
# }

# output "vmss_names" {
#   value = data.external.aks_vmss.result
# }

# locals {
#   usernode_vmss_name = [
#     for vmss_name in [
#       for vmss_name, flag in data.external.aks_vmss.result : 
#       can(regex(var.usernode_poolname, vmss_name)) && flag == "true" ? vmss_name : ""
#     ] : vmss_name if vmss_name != ""
#   ]
# }

# data "azurerm_virtual_machine_scale_set" "this_vmss" {
#   name                = join("", local.usernode_vmss_name)
#   resource_group_name = module.azure-kubernetes-service.node_resource_group
#   depends_on = [ module.azure-kubernetes-service ]
# }


# resource "azapi_resource" "aks_vmss_chaos_target" {
#   type = "Microsoft.Chaos/targets@2023-04-15-preview"
#   name = "Microsoft-VirtualMachineScaleSet"
#   location = module.azure-resource-group.location
#   parent_id = data.azurerm_virtual_machine_scale_set.this_vmss.id
#   depends_on = [ data.azurerm_virtual_machine_scale_set.this_vmss ]
#   body = jsonencode({ properties = {} })
# }

# resource "azurerm_chaos_studio_capability" "example" {
#   chaos_studio_target_id = azapi_resource.aks_vmss_chaos_target.id
#   capability_type        = "Shutdown-2.0"
#   depends_on = [ azapi_resource.aks_vmss_chaos_target ]
# }

# resource "azurerm_chaos_studio_experiment" "example" {
#   location            = module.azure-resource-group.location
#   name                = "vmss-chaos-experiment1"
#   resource_group_name = module.azure-resource-group.name
#   depends_on = [ azurerm_chaos_studio_capability.example ]

#   identity {
#     type = "SystemAssigned"
#   }

#   selectors {
#     name = "Selector1"
#     chaos_studio_target_ids = [azapi_resource.aks_vmss_chaos_target.id]
    
#   }

#   steps {
#     name = "Step1"
#     branch {
#       name = "Branch1"
#       actions {
#         urn = "urn:csci:microsoft:virtualMachineScaleSet:shutdown/2.0"
#         selector_name = "Selector1"
#         parameters = {
#           abruptShutdown = "true"
#         }
#         action_type = "continuous"
#         duration    = "PT2M"
#       }
#     }
#   }
# }