locals {
  ## locals config for key vault firewall rules ##
  kv_net_rules = [
    {
      default_action             = var.keyvault_firewall_default_action
      bypass                     = var.keyvault_firewall_bypass
      ip_rules                   = var.keyvault_firewall_allowed_ips
      virtual_network_subnet_ids = [var.virtual_network_subnet_name]
    }
  ]
}


# locals {
#   # Container App Secrets
#   ca_secrets = [
#     {
#       name  = "openai-api-key"
#       value = "${module.private-chatgpt-openai.openai_primary_key}"
#     },
#     {
#       name  = "openai-api-host"
#       value = "${module.private-chatgpt-openai.openai_endpoint}"
#     }
#   ]

#   # Key Vault Config (with ranodm number suffix)
#   kv_config = {
#     name = "gptkv${random_integer.number.result}"
#     sku  = "standard"
#   }

#   # Custom Domain Config (with ranodm number suffix)
#   custom_domain_config = {
#     zone_name = "gpt${random_integer.number.result}.com"
#     host_name = "PrivateGPT"
#     ttl       = 600
#     tls = [{
#       certificate_type    = "ManagedCertificate"
#       minimum_tls_version = "TLS12"
#     }]
#   }

#   #override the variable values for the WAF name to be unique (for automated tests)
#   cdn_firewall_policy = merge(
#     var.cdn_firewall_policy,
#     { name = "PrivateGPTWAF${random_integer.number.result}" }
#   )

# }