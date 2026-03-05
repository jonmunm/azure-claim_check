# General
variable "rg_name" { type = string }
variable "deployment_id" { type = string }
variable "region" { type = string }

# Storage
variable "main_storage_account_name" { type = string }
variable "main_storage_container_name" { type = string }
variable "main_storage_uami_name" { type = string }
variable "dlq_storage_account_name" { type = string }
variable "dlq_storage_container_name" { type = string }
variable "function_storage_account_name" { type = string }

# Messaging
variable "service_bus_namespace_name" { type = string }
variable "service_bus_topic_name" { type = string }
variable "service_bus_subscription_name" { type = string }
variable "event_grid_name" { type = string }
variable "event_grid_topic_name" { type = string }
variable "event_grid_subscription_name" { type = string }

# Compute
variable "function_plan_name" { type = string }
variable "function_app_name" { type = string }

# My principal ID
variable "personal_principal_id" { type = string }

# Monitoring
variable "la_namespace_name" { type = string }
variable "custom_log_table_name" { type = string }
variable "data_collection_endpoint_name" { type = string }
variable "data_collection_rule_name" { type = string }
variable "app_insights_name" { type = string }
