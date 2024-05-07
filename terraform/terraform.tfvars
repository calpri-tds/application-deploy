tenant_id       = "tennantid"
subscription_id = "subid"

region_code_name = "uw2"
region           = "westus2"
resource_group   = "rg"
rg_resource_num  = "001"
environment      = "prd"

# IPs you wish to access the service
ips = ["172.x.x.132/x"]

# Container registry
sku                   = "Standard"
registry_resource_num = "001"

# Function App networking
funcapp_vnet_resource_num   = "001"
funcapp_vnet_address        = ["172.x.x.x/x"]
funcapp_subnet_resource_num = "001"
funcapp_subnet_address      = ["172.x.x.x/x"]

# App Service Plan
asp_resource_num = "001"
asp_kind         = "elastic"
asp_tier         = "ElasticPremium"
asp_reserved     = true
asp_size         = "EP1"
asp_capacity     = 2

# App insights
application_type        = "web"
appinsight_resource_num = "001"

# Function App
funcapp_resource_num = "001"

# tags
common_tags = {
  env = "PRD"
}
