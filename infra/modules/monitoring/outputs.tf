output "app_insights_key" {
  value = azurerm_application_insights.app_insights.instrumentation_key
}

output "data_collection_rule_id" {
  value = azurerm_monitor_data_collection_rule.dcr.id
}
