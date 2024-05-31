output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
  description = "Kubernetes cluster name"
}
output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
  description = "Kubernetes cluster id"
}
output "kube_admin_config_raw" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config
  description = "Raw Kubernetes admin config"
}

output "cluster_hostnames" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
}

output "cluster_client_certificate" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config[0].client_certificate
  description = "Kubernetes cluster client certificate"
  sensitive = true
}

output "cluster_client_key" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config[0].client_key
  description = "Kubernetes cluster client key"
  sensitive = true
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate
  description = "Kubernetes cluster CA certificate"
  sensitive = true
}

output "username" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config[0].username
  description = "Kubernetes cluster username"
}

output "password" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config[0].password
  description = "Kubernetes cluster password"
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
  description = "Kubernetes cluster node resource group"
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  description = "Kubernetes cluster kubelet identity object id"
}
