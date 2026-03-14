resource "azurerm_log_analytics_workspace" "log_ws" {
  name                = "${var.la_namespace_name}-${var.deployment_id}"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azapi_resource" "custom_logs_table" {
  type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  name      = var.custom_log_table_name
  parent_id = azurerm_log_analytics_workspace.log_ws.id

  body = {
    properties = {
      plan = "Analytics"
      schema = {
        name = var.custom_log_table_name
        columns = [
          { name = "TimeGenerated", type = "datetime" },
          { name = "Sender", type = "string" },
          { name = "RawData", type = "string" }
        ]
      }
      retentionInDays = 30
    }
  }
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "${var.data_collection_endpoint_name}-${var.deployment_id}"
  resource_group_name = var.rg_name
  location            = var.location
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = "${var.data_collection_rule_name}-${var.deployment_id}"
  resource_group_name         = var.rg_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log_ws.id
      name                  = "log-ws-destination"
    }
  }

  data_flow {
    streams       = ["Custom-${var.custom_log_table_name}"]
    destinations  = ["log-ws-destination"]
    transform_kql = "source"
    output_stream = "Custom-${var.custom_log_table_name}"
  }

  stream_declaration {
    stream_name = "Custom-${var.custom_log_table_name}"
    column {
      name = "TimeGenerated"
      type = "datetime"
    }
    column {
      name = "Sender"
      type = "string"
    }
    column {
      name = "RawData"
      type = "string"
    }
  }

  depends_on = [azapi_resource.custom_logs_table]
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${var.app_insights_name}-${var.deployment_id}"
  location            = var.location
  resource_group_name = var.rg_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_ws.id
}

resource "azurerm_application_insights_workbook" "workbook" {
  name                = uuidv5("dns", "claimcheck-workbook-${var.deployment_id}")
  resource_group_name = var.rg_name
  location            = var.location
  display_name        = "Claim Check Monitoring - ${var.deployment_id}"

  # Aquí cargamos el archivo JSON y le pasamos variables
  data_json = templatefile(abspath("${path.module}/workbook.json"), {
    rg_id                    = var.rg_id
    main_storage_account_id  = var.main_storage_account_id
    app_insights_id          = azurerm_application_insights.app_insights.id
    service_bus_namespace_id = var.service_bus_namespace_id
  })

  category = "workbook"
}
