
output "event_grid_system_topic_principal_id" {
  value = azurerm_eventgrid_system_topic.system_topic.identity[0].principal_id
}

output "service_bus_namespace_name" {
  value = azurerm_servicebus_namespace.sb_namespace.name
}

output "service_bus_namespace_id" {
  value = azurerm_servicebus_namespace.sb_namespace.id
}

output "service_bus_topic_name" {
  value = azurerm_servicebus_topic.topic.name
}

output "service_bus_topic_id" {
  value = azurerm_servicebus_topic.topic.id
}

output "service_bus_subcription_id" {
  value = azurerm_servicebus_subscription.consumer.id
}

output "service_bus_subcription_name" {
  value = azurerm_servicebus_subscription.consumer.name
}

