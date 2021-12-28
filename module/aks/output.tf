output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

output "host" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.default.kube_config
  sensitive = true
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.password
}

output "rg_region" {
  value = azurerm_resource_group.default.location
  
}

output "cluster_resource_group" {
  value = azurerm_kubernetes_cluster.default.resource_group_name
}