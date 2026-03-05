output "main_storage_id" {
  value = azurerm_storage_account.main_storage.id
}

output "main_storage_identity_id" {
  value = azurerm_user_assigned_identity.storage_identity.id
}

output "main_storage_uri" {
  value = azurerm_storage_account.main_storage.primary_blob_endpoint
}

output "main_storage_account_name" {
  value = azurerm_storage_account.main_storage.name
}

output "dlq_storage_id" {
  value = azurerm_storage_account.dlq_storage.id
}

output "dlq_storage_container_name" {
  value = azurerm_storage_data_lake_gen2_filesystem.dlq_container.name
}

output "function_storage_id" {
  value = azurerm_storage_account.function_storage.id
}

output "function_storage_acoount_name" {
  value = azurerm_storage_account.function_storage.name
}

output "function_storage_acoount_primary_key" {
  value = azurerm_storage_account.function_storage.primary_access_key
}
