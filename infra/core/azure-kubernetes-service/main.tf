data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}
# data "azuread_group" "this_group" {
#   display_name = var.admin_group_members
# }

###############################################################################################
        ################ Azure Kubernetes Service Setting Up #####################
###############################################################################################


resource "azurerm_kubernetes_cluster" "this" {
  name                          = var.kubernetes_service_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  dns_prefix                    = var.application_code
  oidc_issuer_enabled           = var.oidc_issuer_enabled
  kubernetes_version            = var.kubernetes_version
  private_cluster_enabled       = var.private_cluster_enabled
  automatic_channel_upgrade     = var.automatic_channel_upgrade
  image_cleaner_enabled         = var.image_cleaner_enabled
  image_cleaner_interval_hours  = var.image_cleaner_interval_hours
  local_account_disabled        = false


  default_node_pool {
    name                          = var.systemnode_poolname
    zones                         = var.systemnodes_zones
    vm_size                       = var.systemnode_vm_size
    vnet_subnet_id                = var.systemnode_subnet_id
    enable_auto_scaling           = var.systemnode_enable_auto_scaling
    node_labels                   = var.systemnode_labels
    only_critical_addons_enabled  = var.systemnode_only_critical_addons_enabled
    max_pods                      = var.systemnode_max_pods
    max_count                     = var.systemnode_max_count
    min_count                     = var.systemnode_min_count
    node_count                    = var.systemnode_count
  
  }

  # dynamic "api_server_access_profile" {
  #   for_each = var.private_cluster_enabled == true ? [1] : [0]
  #   content {
  #         vnet_integration_enabled = true
  #         subnet_id                = var.kubernetes_apiserver_subnet_id
  #   }
  # }

  identity {
    type = var.identity
  }
  
  role_based_access_control_enabled = true
  
  network_profile {
    network_plugin      = var.network_plugin
    load_balancer_sku   = var.load_balancer_sku
    outbound_type       = var.outbound_type

  }
  
  http_application_routing_enabled  = var.http_application_routing_enabled
  azure_policy_enabled              = var.azure_policy_enabled
  sku_tier                          = var.sku_tier

  azure_active_directory_role_based_access_control {
    managed = true
    azure_rbac_enabled     = true
    admin_group_object_ids = ["8efbc2c6-37e8-4571-87d5-a1d81bfbd913"]
  }

  oms_agent {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }

  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }
  
  lifecycle {
    ignore_changes = [
      kubernetes_version,
      tags,
      default_node_pool[0].upgrade_settings
    ]
  }

  }

resource "azurerm_kubernetes_cluster_node_pool" "this_user_nodepool" {
  name                  = var.usernode_poolname
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.usernode_vm_size
  node_count            = var.usernode_min_count
  vnet_subnet_id        = var.usernode_subnet_id
  zones                 = var.usernode_zones
  enable_auto_scaling   = true
  mode                  = "User"
  min_count             = var.usernode_min_count
  max_count             = var.usernode_max_count

  depends_on = [ azurerm_kubernetes_cluster.this ]
}


# data "azurerm_public_ip" "this" {
#   name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.this.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
#   resource_group_name = azurerm_kubernetes_cluster.this.node_resource_group
# }

resource "azurerm_role_assignment" "this" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity.0.principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id   = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope           = var.azure_container_registry_id
  depends_on = [ azurerm_kubernetes_cluster.this  ]
}


resource "azurerm_kubernetes_cluster_extension" "gitops-flux" {
  name           = var.gitops_flux_configuration.extension_name
  cluster_id     = azurerm_kubernetes_cluster.this.id
  extension_type = var.gitops_flux_configuration.extension_type
}

resource "azurerm_kubernetes_flux_configuration" "this" {
  name       = "flux-infra-dev"
  cluster_id = azurerm_kubernetes_cluster.this.id
  namespace  = "flux-cluster-configuration"
  scope      = "cluster"

  git_repository {
    url                      = var.gitops_flux_configuration.git_repository_url
    reference_type           = "branch"
    reference_value          = "develop"
    # https_user               = "build"
    # https_key_base64         = base64encode(var.https_key)
    sync_interval_in_seconds = 60
  }

  kustomizations {
    name                       = "base"
    path                       = "./infrastructure/base"
    sync_interval_in_seconds   = 60
    timeout_in_seconds         = 180
    garbage_collection_enabled = true
    recreating_enabled         = true
  }

  kustomizations {
    name                       = "infrastructure"
    path                       = "./infrastructure/dev"
    sync_interval_in_seconds   = 60
    timeout_in_seconds         = 300
    garbage_collection_enabled = true
    recreating_enabled         = true
    depends_on = ["base"]
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.gitops-flux
  ]
}


resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic_setting" {
  name                       = "aks-diagnostic-setting"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }
  enabled_log {
    category = "kube-audit"
  }
  enabled_log {
    category = "kube-audit-admin"
  }
  enabled_log {
    category = "kube-controller-manager"
  }
  enabled_log {
    category = "kube-scheduler"
  }
  enabled_log {
    category = "cluster-autoscaler"
  }
  enabled_log {
    category = "cloud-controller-manager"
  }
  enabled_log {
    category = "guard"
  }
  metric {
    category = "AllMetrics"

  }
  depends_on = [ azurerm_kubernetes_cluster.this ]
}

# ###############################################################################################
#  ################ Nginx Ingress Controller  Configuration # #####################
# ###############################################################################################

# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   version    = "4.8.3" 
#   namespace  = "ingress-nginx"

#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
#     value = "true"
#   }

#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
#     value = "/healthz"
#   }

#   set {
#       name  = "controller.metrics.enabled"
#       value = "true"
#     }

#     set {
#       name  = "controller.metrics.serviceMonitor.enabled"
#       value = "true"
#     }
    
#     set {
#       name  = "controller.metrics.serviceMonitor.additionalLabels.release"
#       value = "prometheus"
#     }

# depends_on = [ kubernetes_namespace.this ]
# }


# ###############################################################################################
#  ################ Prometheus Configuration # #####################
# ###############################################################################################

# resource "helm_release" "prometheus" {
#   name             = "prometheus"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "kube-prometheus-stack"
#   namespace        = "prometheus"
#   create_namespace = true
#   timeout          = 600

#   values = [
#     "${file("${path.module}/configuration/kube-prometheus-stack-custom-values.yaml")}"
#   ]

#   set {
#     name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
#     value = "false"
#   }

#   set {
#     name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
#     value = "false"
#   }
#   depends_on = [ helm_release.prometheus ]
# }

# resource "kubectl_manifest" "ama_metrics_prometheus_config_configmap" {
#   yaml_body = file("${path.module}/configuration/ama-metrics-prometheus-config-configmap.yaml")
#   depends_on = [ helm_release.prometheus ]
# }

# # Apply the ama-metrics-settings-configmap to your cluster.
# resource "kubectl_manifest" "ama_metrics_settings_configmap" {
#   yaml_body = file("${path.module}/configuration/ama-metrics-settings-configmap.yaml")
#   depends_on = [ helm_release.prometheus ]
# }

# ###############################################################################################
