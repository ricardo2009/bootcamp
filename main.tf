# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

}

provider "azurerm" {
  features {}
}

variable "tags" {
  type = map(string)
  default = {
    "cliente"  = "bootcamp"
    "provider" = "terraform"
    "lab"      = "lab"
    "env"      = "prd"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "myresourcegroup"
  location = "westus"
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.tags.cliente}-${var.tags.lab}-${var.tags.env}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "example-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}


output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config_raw

  sensitive = true
}
