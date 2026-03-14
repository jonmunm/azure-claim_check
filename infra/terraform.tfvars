# General
rg_name = "rg-claim-check"
region  = "eastus"

# Storage
main_storage_account_name     = "stclaimcheck"
main_storage_container_name   = "raw-data"
main_storage_uami_name        = "stclaimcheck-uami"
dlq_storage_account_name      = "stdlq"
dlq_storage_container_name    = "failed-messages"
function_storage_account_name = "stfuncconsumer"

# Messaging
service_bus_namespace_name    = "sb-claim-check"
service_bus_topic_name        = "messages"
service_bus_subscription_name = "consumer-subscription"
event_grid_name               = "eg-claim-check"
event_grid_topic_name         = "blobs-created"
event_grid_subscription_name  = "service-bus-subscription"

# Compute
function_plan_name = "asp-funcconsumer"
function_app_name  = "func-consumer"

# Monitoring
la_namespace_name             = "log-ws"
custom_log_table_name         = "EventsLogs_CL"
data_collection_endpoint_name = "python-cli-logs-endpoint"
data_collection_rule_name     = "python-cli-logs-rule"
app_insights_name             = "app-insights"
