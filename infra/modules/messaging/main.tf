resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "${var.service_bus_namespace_name}-${var.deployment_id}"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "topic" {
  name         = "${var.service_bus_topic_name}-${var.deployment_id}"
  namespace_id = azurerm_servicebus_namespace.sb_namespace.id
}

resource "azurerm_servicebus_subscription" "consumer" {
  name               = "${var.service_bus_subscription_name}-${var.deployment_id}"
  topic_id           = azurerm_servicebus_topic.topic.id
  max_delivery_count = 10
  requires_session   = false
}

resource "azurerm_eventgrid_system_topic" "system_topic" {
  name                = "${var.event_grid_name}-${var.deployment_id}"
  resource_group_name = var.rg_name
  location            = var.location
  source_resource_id  = var.main_storage_id
  topic_type          = "Microsoft.Storage.StorageAccounts"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_eventgrid_system_topic_event_subscription" "service_bus_subscription" {
  name                          = "${var.event_grid_subscription_name}-${var.deployment_id}"
  system_topic                  = azurerm_eventgrid_system_topic.system_topic.name
  resource_group_name           = var.rg_name
  service_bus_topic_endpoint_id = azurerm_servicebus_topic.topic.id
  included_event_types          = ["Microsoft.Storage.BlobCreated"]

  storage_blob_dead_letter_destination {
    storage_account_id          = var.dlq_storage_id
    storage_blob_container_name = var.dlq_storage_container_name
  }

  dead_letter_identity {
    type = "SystemAssigned"
  }
}
