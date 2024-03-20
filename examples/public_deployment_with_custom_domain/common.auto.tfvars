### 01 Common Variables + RG ###
resource_group_name = "Nutrisnap-OpenAI-LibreChat-Example"
location            = "SwedenCentral"
tags = {
  Terraform   = "True"
  Description = "Private ChatGPT hosted on Azure OpenAI (Librechat)"
  Author      = "Adam Bloom"
  GitHub      = "https://github.com/Pwd9000-ML/terraform-azurerm-openai-private-chatgpt"
}

### 02 networking ###
virtual_network_name = "demogptvnet"
vnet_address_space   = ["10.3.0.0/24"]
subnet_config = {
  subnet_name                                   = "demogpt-sub"
  subnet_address_space                          = ["10.3.0.0/24"]
  service_endpoints                             = ["Microsoft.AzureCosmosDB", "Microsoft.Web", "Microsoft.KeyVault"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  subnets_delegation_settings = {
    app-service-plan = [
      {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    ]
  }
}

### 03 KeyVault ###
kv_name                  = "demogptkv"
kv_sku                   = "standard"
kv_fw_default_action     = "Deny"
kv_fw_bypass             = "AzureServices"
kv_fw_allowed_ips        = ["0.0.0.0/0"] # Allow all IPs (for demo purposes)
kv_fw_network_subnet_ids = null          # leave null to allow access from default subnet of this module

### 04 Create OpenAI Service ###
oai_account_name                       = "demogptoai"
oai_sku_name                           = "S0"
oai_custom_subdomain_name              = "demogptoai"
oai_dynamic_throttling_enabled         = false
oai_fqdns                              = []
oai_local_auth_enabled                 = true
oai_outbound_network_access_restricted = false
oai_public_network_access_enabled      = true
oai_customer_managed_key               = null
oai_identity = {
  type = "SystemAssigned"
}
oai_network_acls = null
oai_storage      = null
oai_model_deployment = [
  {
    deployment_id  = "gpt-4-vision-preview"
    model_name     = "gpt-4"
    model_format   = "OpenAI"
    model_version  = "vision-preview"
    scale_type     = "Standard"
    scale_capacity = 5
  },
  # {
  #   deployment_id  = "dall-e-3"
  #   model_name     = "dall-e-3"
  #   model_format   = "OpenAI"
  #   model_version  = "3.0"
  #   scale_type     = "Standard"
  #   scale_capacity = 2
  # }
]

### 05 cosmosdb ###
cosmosdb_name                    = "demogptcosmosdb"
cosmosdb_offer_type              = "Standard"
cosmosdb_kind                    = "MongoDB"
cosmosdb_automatic_failover      = false
use_cosmosdb_free_tier           = false
cosmosdb_consistency_level       = "BoundedStaleness"
cosmosdb_max_interval_in_seconds = 10
cosmosdb_max_staleness_prefix    = 200
cosmosdb_geo_locations = [
  {
    location          = "SwedenCentral"
    failover_priority = 0
  }
]
cosmosdb_capabilities                      = ["EnableMongo", "MongoDBv3.4"]
cosmosdb_virtual_network_subnets           = null # leave null to allow access from default subnet of this module
cosmosdb_is_virtual_network_filter_enabled = true
cosmosdb_public_network_access_enabled     = true

### 06 app services (librechat app + meilisearch) ###
# App Service Plan
app_service_name     = "demogptasp"
app_service_sku_name = "B1"

# LibreChat App Service
libre_app_name                          = "demogptchatapp"
libre_app_public_network_access_enabled = true
libre_app_virtual_network_subnet_id     = null # Access is allowed on the built in subnet of this module. If networking is created as part of the module, this will be automatically populated if value is 'null' (priority 100)
libre_app_allowed_subnets               = null # Add any other subnet ids to allow access to the app service (optional)
libre_app_allowed_ip_addresses = [
  {
    ip_address = "0.0.0.0/0" # Allow all IPs (for demo purposes)
    priority   = 200
    name       = "ip-access-rule1"
    action     = "Allow"
  }
]

### LibreChat App Settings ###
# Server Config
libre_app_title         = "NutriSnap Chatbot (DEMO)"
libre_app_custom_footer = "Privately hosted GPT-4-Vision App powered by Azure OpenAI, Azure App Service, and LibreChat"
libre_app_host          = "0.0.0.0"
libre_app_port          = 80
libre_app_docker_image  = "ghcr.io/illgitthat/librechat-dev-api:f7761df52cf6890988bd24da89a22276b2eb2ee0" #v0.6.6 (Pre-release)
libre_app_mongo_uri     = null                                                                            # leave null to use the cosmosdb uri saved in keyvault created by this module
libre_app_domain_client = "http://localhost:80"
libre_app_domain_server = "http://localhost:80"

# debug logging
libre_app_debug_logging = true
libre_app_debug_console = false

# Endpoints
libre_app_endpoints = "azureOpenAI"

# Azure OpenAI
libre_app_az_oai_api_key                      = null # leave null to use the key saved in keyvault created by this module
libre_app_az_oai_models                       = "gpt-4-vision-preview"
libre_app_az_oai_use_model_as_deployment_name = true
libre_app_az_oai_instance_name                = null # leave null to use the instance name created by this module
libre_app_az_oai_api_version                  = "2024-02-15-preview"

# Plugins
libre_app_debug_plugins     = true
libre_app_plugins_creds_key = null # leave null to use the key saved in keyvault created by this module
libre_app_plugins_creds_iv  = null # leave null to use the iv saved in keyvault created by this module

# Search
libre_app_enable_meilisearch = false

# User Registration
libre_app_allow_email_login         = true
libre_app_allow_registration        = true
libre_app_allow_social_login        = false
libre_app_allow_social_registration = false
libre_app_jwt_secret                = null # leave null to use the secret saved in keyvault created by this module
libre_app_jwt_refresh_secret        = null # leave null to use the refresh secret saved in keyvault created by this module

# violations
libre_app_violations = {
  enabled                      = false
  ban_duration                 = 1000 * 60 * 60 * 2
  ban_interval                 = 20
  login_violation_score        = 1
  registration_violation_score = 1
  concurrent_violation_score   = 1
  message_violation_score      = 1
  non_browser_violation_score  = 20
  login_max                    = 7
  login_window                 = 5
  register_max                 = 5
  register_window              = 60
  limit_concurrent_messages    = false
  concurrent_message_max       = 2
  limit_message_ip             = false
  message_ip_max               = 40
  message_ip_window            = 1
  limit_message_user           = false
  message_user_max             = 40
  message_user_window          = 1
}

# Custom Domain and Managed Certificate (Optional)
libre_app_custom_domain_create     = true
librechat_app_custom_domain_name   = "privategptchatbot"
librechat_app_custom_dns_zone_name = "adamcbloom.com"
dns_resource_group_name            = "DNS-Resource-Group-Name"
