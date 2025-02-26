terraform {
  backend "azurerm" {
    resource_group_name   = "tf-az-backend-rg"
    storage_account_name  = "tfazbackend123"
    container_name        = "tf-az-tfstate"
    key                   = "terraform.tfstate"
  }
}