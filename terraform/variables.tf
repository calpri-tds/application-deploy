variable "tenant_id" {
  description = "Tenant ID"
  default     = ""
}

variable "subscription_id" {
  type = string
}

variable "rg_resource_num" {
  type = string
}

variable "environment" {
  type = string
}

variable "region_code_name" {
  type = string
}

variable "region" {
  description = "Region where the resource group will be created"
  default     = "West US 2"
  type        = string
}

variable "ips" {
  description = "IP addresses for access"
}

variable "asp_capacity" {
  description = "Specifies the number of workers associated with this App Service Plan. 0 for function app"
}

variable "asp_resource_num" {
}

variable "asp_kind" {
  description = "The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan)."
}

variable "asp_tier" {
  description = "Specifies the plan's pricing tier. Dynamic for function app"

}
variable "asp_reserved" {
  description = "Specify if the app service plan needs to be reserved"
  default     = true
}

variable "asp_size" {
  description = "Specifies the plan's instance size. Y1 for function app"
}

variable "sku" {
  description = "Specifies the sku for container registry"
}

variable "appinsight_resource_num" {
}

variable "application_type" {
  description = "App insight type"
}

variable "funcapp_vnet_address" {
}

variable "funcapp_subnet_resource_num" {
}

variable "funcapp_subnet_address" {
}

variable "funcapp_vnet_resource_num" {
}

variable "funcapp_resource_num" {
}

variable "registry_resource_num" {
}

variable "common_tags" {
  description = "Map of common tags to apply to the resource"
  type        = map(string)
  default = {
    env = "PRD"

  }
}
