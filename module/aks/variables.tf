
## Resource Group ##variable "resource_group_name" {


variable "tags" {
  type = map(string)
  default = {
    "cliente"  = "bootcamp"
    "provider" = "terraform"
    "lab"      = "lab"
    "env"      = "prd"
    "projeto"  = "terraform"
  }
}

variable "region" {
  type    = string
  default = "eastus2"

}

## AKS ##


variable "app_Id" {
  type      = string
  default   = "8f450002-d867-4426-bb6c-7b667508c79d"
  sensitive = true
}

variable "password" {
  type      = string
  default   = "yBN7Q~Huvd_XDA83jJgXfEdp3aurM5xbPsP1P"
  sensitive = true

}