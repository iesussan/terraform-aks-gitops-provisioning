output "resource_group_name" {
    description = "Resource Group Name"
    value = module.azure-resource-group.name
}

output "resource_group_location" {
    description = "Resource Group Location"
    value = module.azure-resource-group.location
}

output "resource_group_id" {
    description = "Resource Group Id"
    value = module.azure-resource-group.id
}

#virtual network outputs
output "azure_virtual_network_name" {
    description = "Virtual Network Name"
    value = module.azure-virtual-networks.azure_virtual_network_name
}

output "azure_virtual_network_id" {
    description = "Virtual Network Id"
    value = module.azure-virtual-networks.azure_virtual_network_id
}

output "azure_virtual_network_subnet_info" {
    description = "Virtual Network Subnet Info"
    value = module.azure-virtual-networks.subnet_info
}
output "kube_admin_config_raw" {
  value = module.azure-kubernetes-service.kube_admin_config_raw
  description = "Raw Kubernetes admin config"
  sensitive = true
}