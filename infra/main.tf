provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    version = ">=2.0"
    features {}
}

resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix          = var.dns_prefix
    kubernetes_version  = "1.17.3"

    default_node_pool {
        name            = "default"
        node_count      = var.agent_count
        vm_size         = "Standard_DS2_v2"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    role_based_access_control {
        enabled = false
    }

    tags = {
        Environment = "Development"
    }
}

resource "azurerm_resource_group" "example" {
  name     = "mssql"
  location = "West Europe"
}

resource "azurerm_sql_server" "example" {
    name                         = "mssql-paas"
    resource_group_name          = azurerm_resource_group.example.name
    location                     = "West Europe"
    version                      = "12.0"
    administrator_login          = "houssem"
    administrator_login_password = "@Aa123456"
}

resource "azurerm_storage_account" "example" {
    name                     = "mssqlstorageaccount"
    resource_group_name      = azurerm_resource_group.example.name
    location                 = azurerm_resource_group.example.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_sql_database" "example" {
    name                = "ProductsDB"
    resource_group_name = azurerm_resource_group.example.name
    location            = "West Europe"
    server_name         = azurerm_sql_server.example.name
    create_mode         = "Default"
    edition             = "Standard"

    tags = {
        environment = "production"
    }
}