# create a rg
resource "azurerm_resource_group" "resource-group" {
  name     = "${var.PROJECT_COMMON_NAME}-${var.ENVIRONMENT}"
  location = var.AZURE_REGION
}
