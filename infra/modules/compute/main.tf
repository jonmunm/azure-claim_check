resource "azurerm_service_plan" "function_plan" {
  name                = "${var.function_plan_name}-${var.deployment_id}"
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                = "${var.function_app_name}-${var.deployment_id}"
  resource_group_name = var.rg_name
  location            = var.location

  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = var.function_storage_account_name
  storage_account_access_key = var.function_storage_account_primary_key

  site_config {
    application_stack { python_version = "3.11" }
  }

  identity { type = "SystemAssigned" }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                = var.app_insights_key
    "ServiceBusConnection__fullyQualifiedNamespace" = "${var.service_bus_namespace_name}.servicebus.windows.net"
    "SERVICE_BUS_TOPIC_NAME"                        = var.service_bus_topic_name
    "SERVICE_BUS_SUBSCRIPTION_NAME"                 = var.service_bus_subscription_name
    "AzureWebJobsStorage__accountName"              = var.function_storage_account_name
    "AzureWebJobsStorage__credential"               = "managedidentity"
    "AZURE_MONITOR_METRICS_URL"                     = "https://eastus.monitoring.azure.com${var.main_storage_id}/metrics"
  }
}
