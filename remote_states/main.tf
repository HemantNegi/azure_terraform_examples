# the secrets for this provider are genearated from `create_service_principal` component

provider "azurerm" {
  alias = "dev"
  version = "~> 1.42.0"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}


resource "azurerm_resource_group" "rg" {
  provider = "azurerm.dev"
  name     = "shemant-test-resourcegroup1"
  location = "westus2"

  tags = { "Name" = "shemant-test-resourcegroup1" }
}

#### WIP