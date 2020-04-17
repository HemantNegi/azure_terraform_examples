# the secrets for this provider are genearated from `create_service_principal` component
provider "azurerm" {
  alias           = "low_priviledged"
  version         = "~> 1.42.0"

  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

resource "azurerm_resource_group" "rg" {
  provider = "azurerm.low_priviledged"
  name     = "test_resource_group"
  location = "westus2"
}

resource "azurerm_resource_group" "example" {
  provider = "azurerm.low_priviledged"
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  provider                 = "azurerm.low_priviledged"
  name                     = "examplestoracc"
  resource_group_name      = "${azurerm_resource_group.example.name}"
  location                 = "${azurerm_resource_group.example.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  provider              = "azurerm.low_priviledged"
  name                  = "content"
  storage_account_name  = "${azurerm_storage_account.example.name}"
  container_access_type = "private"
}
