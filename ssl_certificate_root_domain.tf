# Generate a private key for LetsEncrypt account
resource "tls_private_key" "root-domain-reg-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an LetsEncrypt registration
resource "acme_registration" "root-domain-acme-registration" {
  account_key_pem = tls_private_key.root-domain-reg-private-key.private_key_pem
  email_address   = var.LETSENCRYPT_EMAIL
}


resource "acme_certificate" "root-domain-certificate" {
  account_key_pem               = acme_registration.root-domain-acme-registration.account_key_pem
  common_name                   = azurerm_dns_zone.external-dns-zone.name
  key_type                      = 4096
  min_days_remaining            = 45
  revoke_certificate_on_destroy = false
  dns_challenge {
    provider = "azuredns"
    config = {
      AZURE_CLIENT_ID           = var.CLIENT_ID
      AZURE_CLIENT_SECRET       = var.CLIENT_SECRET
      AZURE_SUBSCRIPTION_ID     = var.SUBSCRIPTION_ID
      AZURE_TENANT_ID           = var.TENANT_ID
      AZURE_RESOURCE_GROUP      = azurerm_resource_group.resource-group.name
      AZURE_ZONE_NAME           = azurerm_dns_zone.external-dns-zone.name
      AZURE_ENVIRONMENT         = "public"
      AZURE_PROPAGATION_TIMEOUT = "3600"
      AZURE_TTL                 = "360"
      AZURE_POLLING_INTERVAL    = "60"
    }
  }
  depends_on = [time_sleep.sleep-10-minutes-after-making-dns-zone]
}

# create a random 8 char lowercase string
resource "random_string" "root-domain-random-string" {
  length     = 10
  special    = false
  upper      = false
  depends_on = [acme_certificate.root-domain-certificate]
}

resource "azurerm_key_vault_certificate" "root-domain-certificate" {
  name         = "root-domain-cert-kv-${random_string.root-domain-random-string.result}"
  key_vault_id = azurerm_key_vault.key_vault.id
  certificate {
    contents = acme_certificate.root-domain-certificate.certificate_p12
    password = ""
  }
  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    key_properties {
      exportable = true
      reuse_key  = true
      key_type   = "RSA"
      key_size   = 4096
    }
  }
}
