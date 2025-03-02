terraform {
  backend "azurerm" {
    resource_group_name  = "tf-az-backend-rg"
    storage_account_name = "tfazbackend123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    subscription_id      = "256c47d7-6c5f-4e92-b116-d234771e3690"
  }
}