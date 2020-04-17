
output "service_principal_id" {
  value = "${azuread_service_principal.sp.id}"
}

output "client_id" {
  value = "${azuread_service_principal.sp.application_id}"
}

output "client_secret" {
  value = "${random_password.rnd_password.result}"
}

output "azurerm_subscription_id" {
  value = "${data.azurerm_subscription.primary.subscription_id}"
}

output "azurerm_subscription_tenant_id" {
  value = "${data.azurerm_subscription.primary.tenant_id}"
}
