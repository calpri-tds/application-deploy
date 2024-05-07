terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.102.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "subscription-id"
}

# This is an assumption a storage account exists with the correct access so we can create a tf state file in a container called everflow-tf
  
terraform {
  backend "azurerm" {
    resource_group_name  = "test01"
    storage_account_name = "tf"
    container_name       = "tfstate"
    key                  = "tech-test"
    use_azuread_auth     = true
    subscription_id      = "subscription-id"
    tenant_id            = "tennant-id"
  }
}

# Get existing resource group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

# Create acr and allow the subnet created later in the tf and allow the ips specificed in the tf variables
resource "azurerm_container_registry" "container_registry" {
  name                = "${var.environment}armacr${var.region_code_name}${var.registry_resource_num}"
  resource_group_name = "${var.environment}armrgp${var.rg_resource_num}"
  location            = var.region
  sku                 = var.sku
  admin_enabled       = false

  network_rule_set {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.func_app_subnet.id]
    ip_rule {
      action              = "Allow"
      ip_address_or_range = var.ips
    }
  }

  tags = var.common_tags
}

# Create a vnet for the func app
resource "azurerm_virtual_network" "func_app_vnet" {
  name                = "${var.environment}armvnt${var.region_code_name}${var.funcapp_vnet_resource_num}"
  resource_group_name = "${var.environment}armrgp${var.rg_resource_num}"
  location            = var.region
  address_space       = var.funcapp_vnet_address
  tags                = var.common_tags
}

# Create a subnet for the app
resource "azurerm_subnet" "func_app_subnet" {
  name                 = "${var.environment}armsub${var.region_code_name}${var.funcapp_subnet_resource_num}"
  resource_group_name  = "${var.environment}armrgp${var.rg_resource_num}"
  virtual_network_name = azurerm_virtual_network.func_app_vnet.name
  address_prefixes     = var.funcapp_subnet_address
}

# Create the nsg
resource "azurerm_network_security_group" "func_app_nsg" {
  name                = "${var.environment}armnsg${var.region_code_name}${var.funcapp_vnet_resource_num}"
  resource_group_name = "${var.environment}armrgp${var.rg_resource_num}"
  location            = var.region
  tags                = var.common_tags
}

# Create the asp, used premium since it's PRD, could change if it was for a lower env to save money 
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.environment}armasp${var.region_code_name}${var.asp_resource_num}"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.resource_group.name
  kind                = var.asp_kind
  reserved            = var.asp_reserved
  sku {
    tier     = var.asp_tier
    size     = var.asp_size
    capacity = var.asp_capacity
  }
  tags = var.common_tags
}

# Create application insights
resource "azurerm_application_insights" "application_insights" {
  name                = "${var.environment}armins${var.region_code_name}${var.appinsight_resource_num}"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.resource_group.name
  application_type    = var.application_type
  tags                = var.common_tags
}

# Create the function app that uses app insights and asp
resource "azurerm_function_app" "func_app" {
  name                = "${var.environment}armfnc${var.region_code_name}${var.funcapp_resource_num}"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings        = merge({ "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key, "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.application_insights.connection_string }) # This allows for the app service to connect to app insights
  tags                = var.common_tags
}

# App vnet integration for function app
resource "azurerm_app_service_virtual_network_swift_connection" "func-app-network" {
  app_service_id = azurerm_function_app.func-app.id
  subnet_id      = azurerm_subnet.func_app_subnet.id
}

# Some app insight alerts, very basic 
resource "azurerm_monitor_metric_alert" "high_request_count_alert" {
  name                = "high-request-count-alert"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  target_resource_id  = azurerm_application_insights.application_insights.id
  scopes              = [azurerm_application_insights.application_insights.id]
  description         = "Alert triggered when request count exceeds a certain threshold - please investigate this p1"
  enabled             = true

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/count"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000
  }

  action {
    action_group_id = "action-group-id" # This is an alert group defined for who to send alerts to
  }
}

# This is the alert group, just using an example email address 
resource "azurerm_monitor_action_group" "action_group" {
  name                = "action-group"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  short_name          = "support"
  location            = var.region
  email_receiver {
    name                    = "support-user"
    email_address           = "p1-alert@test.com"
    use_common_alert_schema = true
  }
}
