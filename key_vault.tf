data "azurerm_client_config" "current" {}


# Create a Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                = "${var.PROJECT_COMMON_NAME}-${var.ENVIRONMENT}-kv"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  sku_name            = "standard"
  tenant_id           = var.TENANT_ID
  #   soft_delete_enabled             = false
  enabled_for_disk_encryption     = true
  purge_protection_enabled        = false
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  soft_delete_retention_days      = 14

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}


resource "azurerm_key_vault_access_policy" "key-vault-access-policy-from-terraform" {
  # this is required so that terraform can push keys, secrets, and certificates to the key vault
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]
}

data "azuread_service_principal" "azure-cdn-service-principal" {
  client_id = "205478c0-bd83-4e1b-a9d6-db63a3e1e1c8"
}

resource "azurerm_key_vault_access_policy" "azure-cdn-kv-access-policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  object_id    = data.azuread_service_principal.azure-cdn-service-principal.object_id
  tenant_id    = var.TENANT_ID
  secret_permissions = [
    "Get",
    "List",
    # "Purge",
    # "Delete"
  ]
  key_permissions = [
    "Get",
    "List",
    # "Purge",
    # "Delete"
  ]
  certificate_permissions = [
    "Get",
    "List",
    # "Purge",
    # "Delete"
  ]
}

data "azuread_service_principal" "microsoft-web-app-service-principal" {
  client_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
}

resource "azurerm_key_vault_access_policy" "web-app-kv-access-policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  object_id    = data.azuread_service_principal.microsoft-web-app-service-principal.object_id
  tenant_id    = var.TENANT_ID
  secret_permissions = [
    "Get",
    "List",
    # "Purge",
    # "Delete"
  ]
  key_permissions = [
    "Get",
    "List",
    # "Purge",
    # "Delete"
  ]
  certificate_permissions = [
    "Get",
    "List",
    # "Purge",
    # "Delete"
  ]
}
