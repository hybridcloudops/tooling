resource "azurerm_resource_group" "bsc" {
  name     = var.resource_group_name
  location = var.region
}

# is created in the process but not removed anymore
# create explicitly and see if it gets removed on delete
resource "azurerm_resource_group" "nw_watch" {
  name     = "NetworkWatcherRG"
  location = var.region
}

resource "azurerm_kubernetes_cluster" "bsc" {
  name                = var.k8_name
  location            = azurerm_resource_group.bsc.location
  resource_group_name = azurerm_resource_group.bsc.name
  dns_prefix          = var.k8_dns_prefix

  tags = {
    Environment = "Production"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2S"
  }

  service_principal {
    client_id     = var.arm_client_id
    client_secret = var.arm_client_secret
  }
}

