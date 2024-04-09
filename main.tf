terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.77.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.44.1"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.18.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
  }
  required_version = ">= 1.1.0"
  backend "azurerm" {
    # will get configured with -backend-config= in the terraform init -upgrade command
    # the backend config file will be created using envsubst and provider_secrets_template file
    # env vars are set in the github action
    # env vars used in provider_secrets_template file are also used in the variable blocks below
    # to configure the azurerm provider
  }
}

provider "azurerm" {
  features {
    key_vault {
      # purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults   = false
      recover_soft_deleted_certificates = false
      recover_soft_deleted_secrets      = false
      recover_soft_deleted_keys         = false
    }
    template_deployment {
      delete_nested_items_during_deletion = false
    }
  }
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  client_id       = var.CLIENT_ID
  client_secret   = var.CLIENT_SECRET
}

provider "azuread" {
  tenant_id     = var.TENANT_ID
  client_id     = var.CLIENT_ID
  client_secret = var.CLIENT_SECRET
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "tls" {

}

provider "random" {

}

variable "SUBSCRIPTION_ID" {
  type = string
}

variable "TENANT_ID" {
  type = string
}

variable "CLIENT_ID" {
  type = string
}

variable "CLIENT_SECRET" {
  type = string
}

variable "ENVIRONMENT" {
  type = string

}
