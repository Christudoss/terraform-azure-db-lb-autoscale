terraform {
  required_version = ">= 0.12" 
}

resource "azurerm_storage_account" "neudesic" {
  name                     = "irwintest"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "neudesic" {
  name                         = "irwin-test"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "adm"
  administrator_login_password = "Password123"

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.neudesic.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.neudesic.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
}

resource "azurerm_mssql_database" "neudesic" {
  name           = "irwin-db-d"
  server_id      = azurerm_sql_server.neudesic.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = false
  sku_name       = "GP_Gen5_2"
  zone_redundant = false

  tags = {
    foo = "neudesic"
  }

}
