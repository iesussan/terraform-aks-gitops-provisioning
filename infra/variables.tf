# Input variables for the module azure-resource-group
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "resource_group_tags" {}
# Input variables for the module azure-virtual-networks
variable "virtual_network_exists" {}
variable "azure_bastion_exists" {}
variable "virtual_network_name" {}
variable "virtual_network_address_space" {}
variable "virtual_network_subnets" {}
# Input variables for the module azure-container-registry
variable "container_registry_name" {}
variable "acr_sku"{}
# Input variables for the module azure-log-analytics-workspace
variable "log_analytics_workspace_name" {}
variable "log_analytics_workspace_sku" {}
variable "log_analytics_workspace_retention_in_days" {}
# Input variables for the module azure-kubernetes-service
variable "private_cluster_enabled" {}
variable "kubernetes_service_name" {}
variable "systemnode_poolname" {}
variable "systemnodes_zones" {}
variable "systemnode_count" {}
variable "systemnode_vm_size" {}
variable "identity" {}
variable "network_plugin" {}
variable "load_balancer_sku" {}
variable "application_code" {}
variable "kubernetes_configuration" {}
variable "admin_group_members" {}
variable "usernode_poolname" {}
variable "usernode_zones" {}
variable "usernode_vm_size" {}
variable "usernode_min_count" {}
variable "usernode_max_count" {}
variable "kubernetes_version" {}
variable "gitops_flux_configuration" {}
# Input variables for aks monitoring
variable "azurerm_monitor_workspace_name" {}
# Input variables for prometheus dashboard
variable "azurerm_dashboard_grafana_name" {}