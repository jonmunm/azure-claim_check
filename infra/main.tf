resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}-${var.deployment_id}"
  location = var.region
}

module "storage" {
  source                        = "./modules/storage"
  location                      = var.region
  rg_name                       = azurerm_resource_group.rg.name
  deployment_id                 = var.deployment_id
  main_storage_account_name     = var.main_storage_account_name
  main_storage_uami_name        = var.main_storage_uami_name
  main_storage_container_name   = var.main_storage_container_name
  dlq_storage_account_name      = var.dlq_storage_account_name
  dlq_storage_container_name    = var.dlq_storage_container_name
  function_storage_account_name = var.function_storage_account_name
}

module "messaging" {
  source                        = "./modules/messaging"
  location                      = azurerm_resource_group.rg.location
  rg_name                       = azurerm_resource_group.rg.name
  deployment_id                 = var.deployment_id
  service_bus_namespace_name    = var.service_bus_namespace_name
  service_bus_topic_name        = var.service_bus_topic_name
  event_grid_name               = var.event_grid_name
  main_storage_id               = module.storage.main_storage_id
  event_grid_topic_name         = var.event_grid_topic_name
  event_grid_subscription_name  = var.event_grid_subscription_name
  dlq_storage_id                = module.storage.dlq_storage_id
  dlq_storage_container_name    = module.storage.dlq_storage_container_name
  service_bus_subscription_name = var.service_bus_subscription_name
}

module "monitoring" {
  source                        = "./modules/monitoring"
  location                      = var.region
  rg_name                       = azurerm_resource_group.rg.name
  deployment_id                 = var.deployment_id
  la_namespace_name             = var.la_namespace_name
  custom_log_table_name         = var.custom_log_table_name
  data_collection_endpoint_name = var.data_collection_endpoint_name
  data_collection_rule_name     = var.data_collection_rule_name
  app_insights_name             = var.app_insights_name
  rg_id                         = azurerm_resource_group.rg.id
  main_storage_account_id       = module.storage.main_storage_id
  service_bus_namespace_id      = module.messaging.service_bus_namespace_id
}

module "compute" {
  source                               = "./modules/compute"
  location                             = azurerm_resource_group.rg.location
  rg_name                              = azurerm_resource_group.rg.name
  deployment_id                        = var.deployment_id
  function_app_name                    = var.function_app_name
  function_plan_name                   = var.function_plan_name
  service_bus_namespace_name           = module.messaging.service_bus_namespace_name
  service_bus_topic_name               = module.messaging.service_bus_topic_name
  service_bus_subscription_name        = module.messaging.service_bus_subcription_name
  app_insights_key                     = module.monitoring.app_insights_key
  function_storage_account_name        = module.storage.function_storage_acoount_name
  function_storage_account_primary_key = module.storage.function_storage_acoount_primary_key
  main_storage_id                      = module.storage.main_storage_id
}

module "iam" {
  source                               = "./modules/iam"
  location                             = azurerm_resource_group.rg.location
  rg_name                              = azurerm_resource_group.rg.name
  event_grid_system_topic_principal_id = module.messaging.event_grid_system_topic_principal_id
  dlq_storage_id                       = module.storage.dlq_storage_id
  main_storage_id                      = module.storage.main_storage_id
  service_bus_topic_id                 = module.messaging.service_bus_topic_id
  function_app_principal_id            = module.compute.function_app_principal_id
  service_bus_subscription_id          = module.messaging.service_bus_subcription_id
  personal_principal_id                = var.personal_principal_id
  function_storage_id                  = module.storage.function_storage_id
  data_collection_rule_id              = module.monitoring.data_collection_rule_id
}


