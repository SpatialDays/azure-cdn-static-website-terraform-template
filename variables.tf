variable "DOMAIN_NAME" {
  type = string
}

variable "PROJECT_COMMON_NAME" {
  type = string
}

variable "LETSENCRYPT_EMAIL" {
  type = string
}

variable "AZURE_REGION" {
  type    = string
  default = "ukwest"

}
