resource "azurerm_role_assignment" "my_user_storage_contributor" {
  scope                = var.main_storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.personal_principal_id
}

resource "azurerm_role_assignment" "event_grid_storage_contributor" {
  scope                = var.dlq_storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.event_grid_system_topic_principal_id
}

resource "azurerm_role_assignment" "function_app_function_storage_contributor" {
  scope                = var.function_storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.function_app_principal_id
}

resource "azurerm_role_assignment" "function_app_main_storage_contributor" {
  scope                = var.main_storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.function_app_principal_id
}

resource "azurerm_role_assignment" "event_grid_sb_sender" {
  scope                = var.service_bus_topic_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.event_grid_system_topic_principal_id
}

resource "azurerm_role_assignment" "function_app_sb_receiver" {
  scope                = var.service_bus_subscription_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.function_app_principal_id
}

resource "azurerm_role_assignment" "my_user_sb_receiver" {
  scope                = var.service_bus_subscription_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.personal_principal_id
}

resource "azurerm_role_assignment" "lite_worker_metric_publisher" {
  scope                = var.main_storage_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = var.function_app_principal_id
}

resource "azurerm_role_assignment" "my_user_metric_publisher" {
  scope                = var.main_storage_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = var.personal_principal_id
}

resource "azurerm_role_assignment" "my_user_dcr_metric_publisher" {
  scope                = var.data_collection_rule_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = var.personal_principal_id
}
