resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "${var.main_storage_uami_name}-${var.deployment_id}"
  resource_group_name = var.rg_name
  location            = var.location
}

resource "azurerm_storage_account" "main_storage" {
  name                     = "${var.main_storage_account_name}${var.deployment_id}" # Debe ser único globalmente
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_identity.id]
  }

  default_to_oauth_authentication = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "raw_data_container" {
  name               = var.main_storage_container_name
  storage_account_id = azurerm_storage_account.main_storage.id
}

resource "azurerm_role_assignment" "storage_owner" {
  scope                = azurerm_storage_account.main_storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}

resource "azurerm_storage_account" "dlq_storage" {
  name                            = "${var.dlq_storage_account_name}${var.deployment_id}" # Debe ser único globalmente
  resource_group_name             = var.rg_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  default_to_oauth_authentication = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "dlq_container" {
  name               = var.dlq_storage_container_name
  storage_account_id = azurerm_storage_account.dlq_storage.id
}

resource "azurerm_storage_account" "function_storage" {
  name                     = "${var.function_storage_account_name}${var.deployment_id}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
