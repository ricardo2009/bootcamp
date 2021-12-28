resource "random_pet" "prefix" {}

provider "azurerm" {}

resource "azurerm_resource_group" "default" {
    name = "$(random_pet.prefix.id)-id"
    location = "eastus2"
    tags = {
      bootcamp = "demo"
    }
}

resource "azurerm_kubernetes_cluster" "default" {
    name = "$(random_pet.prefix.id)-aks"
    location = azurerm_resource_group.default.location
    resource_group_name = azurerm_resource_group.default.name
    dns_prefix = "$(random_pet.prefix.id)-k8s"

    default_node_pool {
        name = "default"
        node_count = 2
        vm_size = "Standard_DS2_v2"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id =  var.appId#"${data.azurerm_client_config.current.client_id}"
        client_secret = var.password #"${data.azurerm_client_config.current.client_secret}"
    }

    role_based_access_control {
        enabled = true
    }

    tags = {
        environment = "Production"
    }

  
}

