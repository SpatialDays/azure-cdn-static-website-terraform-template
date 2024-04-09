resource "azurerm_storage_account" "landing-page-storage-account" {
  name                     = "${var.PROJECT_COMMON_NAME}${var.ENVIRONMENT}"
  resource_group_name      = azurerm_resource_group.resource-group.name
  location                 = azurerm_resource_group.resource-group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_cdn_profile" "landing-page-cdn-profile" {
  name                = "${var.PROJECT_COMMON_NAME}${var.ENVIRONMENT}cdnprof"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = "global"
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "landing-page-cdn-endpoint" {
  name                = "${var.PROJECT_COMMON_NAME}${var.ENVIRONMENT}ldngcdnendpnt"
  profile_name        = azurerm_cdn_profile.landing-page-cdn-profile.name
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = "global"
  origin_host_header  = azurerm_storage_account.landing-page-storage-account.primary_web_host
  origin {
    name      = azurerm_storage_account.landing-page-storage-account.name
    host_name = azurerm_storage_account.landing-page-storage-account.primary_web_host
  }

  #   delivery_rule {
  #     name  = "sparewriterule"
  #     order = 1
  #     url_file_extension_condition {
  #       operator = "LessThan"
  #       match_values = [
  #         "1"
  #       ]
  #     }
  #     url_rewrite_action {
  #       source_pattern          = "/"
  #       destination             = "/index.html"
  #       preserve_unmatched_path = false
  #     }
  #   }
  delivery_rule {
    name  = "httptohttpsredirect"
    order = 1
    request_scheme_condition {
      operator = "Equal"
      match_values = [
        "HTTP"
      ]
    }
    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }
}



resource "azurerm_dns_a_record" "landing-page-cdn-dns-record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.external-dns-zone.name
  resource_group_name = azurerm_resource_group.resource-group.name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_endpoint.landing-page-cdn-endpoint.id
  depends_on          = [time_sleep.sleep-10-minutes-after-making-dns-zone]

}

resource "azurerm_dns_cname_record" "landing-page-cdn-dns-record-verify" {
  name                = "cdnverify"
  zone_name           = azurerm_dns_zone.external-dns-zone.name
  resource_group_name = azurerm_resource_group.resource-group.name
  ttl                 = 300
  record              = "cdnverify.${azurerm_cdn_endpoint.landing-page-cdn-endpoint.fqdn}"
  depends_on          = [time_sleep.sleep-10-minutes-after-making-dns-zone]
}



resource "azurerm_cdn_endpoint_custom_domain" "landing-page-cdn-custom-domain" {
  name            = "${var.PROJECT_COMMON_NAME}${var.ENVIRONMENT}cdnendpntcustdom"
  cdn_endpoint_id = azurerm_cdn_endpoint.landing-page-cdn-endpoint.id
  host_name       = azurerm_dns_zone.external-dns-zone.name

  user_managed_https {
    key_vault_secret_id = azurerm_key_vault_certificate.root-domain-certificate.versionless_secret_id
  }
  depends_on = [azurerm_key_vault_access_policy.azure-cdn-kv-access-policy, azurerm_dns_a_record.landing-page-cdn-dns-record, azurerm_dns_cname_record.landing-page-cdn-dns-record-verify]

}
