# Create a storage account and store a file in it.
provider "azurerm" {
  version  = "~> 2.3"
  features = {}
}

resource "azurerm_resource_group" "storage_rg" {
  name     = "hemant-test-storage"
  location = "West Europe"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "hemantstorageaccount"
  resource_group_name      = "${azurerm_resource_group.storage_rg.name}"
  location                 = "${azurerm_resource_group.storage_rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "hemantcontainer"
  storage_account_name  = "${azurerm_storage_account.storage_account.name}"
  container_access_type = "private"
}

# store a file from local machine.
resource "azurerm_storage_blob" "blob" {
  name                   = "downoad.png"
  storage_account_name   = "${azurerm_storage_account.storage_account.name}"
  storage_container_name = "${azurerm_storage_container.storage_container.name}"
  type                   = "Block"
  source                 = "/Users/shemant/Desktop/download.png"
}
