output "resource_group_id" {
  value = "${azurerm_resource_group.storage_rg.id}"
}

output "storage_account_id" {
  value = "${azurerm_storage_account.storage_account.id}"
}

output "storage_account_primary_access_key" {
  value = "${azurerm_storage_account.storage_account.primary_access_key }"
}

output "storage_account_secondary_access_key" {
  value = "${azurerm_storage_account.storage_account.secondary_access_key}"
}

output "storage_account_primary_connection_string" {
  value = "${azurerm_storage_account.storage_account.primary_connection_string}"
}

output "storage_account_secondary_connection_string" {
  value = "${azurerm_storage_account.storage_account.secondary_connection_string}"
}

output "storage_account_primary_blob_connection_string" {
  value = "${azurerm_storage_account.storage_account.primary_blob_connection_string}"
}

output "storage_account_secondary_blob_connection_string" {
  value = "${azurerm_storage_account.storage_account.secondary_blob_connection_string}"
}

output "storage_container_name" {
  value = "${azurerm_storage_container.storage_container.name}"
}
