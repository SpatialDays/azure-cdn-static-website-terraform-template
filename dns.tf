

resource "azurerm_dns_zone" "external-dns-zone" {
  name                = var.DOMAIN_NAME
  resource_group_name = azurerm_resource_group.resource-group.name
  soa_record {
    email = "admin.${var.DOMAIN_NAME}"
  }
}

# sleep job for 10 minutes after the DNS zone is created so that engineer can go and add the NS records to the domain registrar
resource "time_sleep" "sleep-10-minutes-after-making-dns-zone" {
  depends_on      = [azurerm_dns_zone.external-dns-zone]
  create_duration = "10m"
}
