data "azurerm_kubernetes_cluster" "default" {
    name = "[output(kubernetes_cluster_name)]"
    location = var.region
}