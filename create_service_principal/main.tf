# below both providers get authenticated by Azure CLI
provider "azuread" {}

provider "azurerm" {
  features {}
}

# Create an application
resource "azuread_application" "app" {
  name                       = "HemantExampleApp"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false                # Other AAD tenants
  oauth2_allow_implicit_flow = false
  type                       = "webapp/api"

  //owners                     = ["00000004-0000-0000-c000-000000000000"]  # Default is current user
}

# Create a service principal for application.
resource "azuread_service_principal" "sp" {
  application_id = "${azuread_application.app.application_id}"
}

resource "random_password" "rnd_password" {
  length  = 32
  special = false
}

resource "azuread_service_principal_password" "sp_password" {
  service_principal_id = "${azuread_service_principal.sp.id}"
  value                = "${random_password.rnd_password.result}"
  end_date_relative    = "87600h"  # 360 days (supports go style durations)
}

data "azurerm_subscription" "primary" {}

# Assign contributer role to the service principal.
resource "azurerm_role_assignment" "subscription_acces" {
  scope                = "${data.azurerm_subscription.primary.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal.sp.id}"
}

//# Configure the Microsoft Azure Active Directory Provider
//provider "azuread" {
//  version = "=0.7.0"
//  alias = "dev"
//}
//provider "azurerm" {
//  features {}
//}
//
//
//# Create an application
//resource "azuread_application" "app" {
//  provider = "azuread.dev"
//  name = "HemantExampleApp"
//  homepage                   = "https://homepage"
//  identifier_uris            = ["https://uri"]
//  reply_urls                 = ["https://replyurl"]
//  available_to_other_tenants = false
//  type                       = "webapp/api"
//  //  owners                     = ["00000004-0000-0000-c000-000000000000"] # default is current user
//
//  // allow access to resources and there apis
////  required_resource_access {
////    # Microsoft Graph
////    resource_app_id = "00000003-0000-0000-c000-000000000000"
////
////      resource_access {
////        # Read privileged access to Azure resources
////        id   = "1d89d70c-dcac-4248-b214-903c457af83a"
////        type = "Scope"
////      }
//
////    resource_access {
////      # Allows the app to read data in your organization's directory, such as users, groups and apps, without a signed-in user.
////      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
////      type = "Role"
////    }
////    resource_access {
////      # Allows the app to read data in your organization's directory, such as users, groups and apps.
////      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
////      type = "Scope"
////    }
////    resource_access {
////      # Allows users to sign-in to the app, and allows the app to read the profile of signed-in users. It also allows the app to read basic company information of signed-in users.
////      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
////      type = "Scope"
////    }
////  }
//
////  required_resource_access {
////    # Azure Active Directory
////    resource_app_id = "00000002-0000-0000-c000-000000000000"
////    resource_access {
////      # Sign in and read user profile
////      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
////      type = "Scope"
////    }
////
////    resource_access {
////      # Read privileged access to Azure resources
////      id   = "a42657d6-7f20-40e3-b6f0-cee03008a62a"
////      type = "Scope"
////    }
////  }
//
////  # az ad sp show --id  630af071-ee25-49d3-8b08-ee41761328c0
////  # These are the roles created for this application that other apps can ask access for.
////  app_role {
////    allowed_member_types = [
////      "User",
////      "Application",
////    ]
////
////    description  = "Admins can manage roles and perform all task actions"
////    display_name = "Admin"
////    is_enabled   = true
////    value        = "Admin"
////  }
//}
//
//# Create a service principal
//resource "azuread_service_principal" "sp" {
//  provider = "azuread.dev"
//  application_id = "${azuread_application.app.application_id}"
////  app_role_assignment_required = true
//}
//
//
//resource "random_password" "main" {
//  length  = 32
//  special = false
//}
//
//resource "azuread_service_principal_password" "main" {
//  service_principal_id = "${azuread_service_principal.sp.id}"
//  value = "${random_password.main.result}"
//  end_date_relative = "87600h" # 360 days
//}
//
//data "azurerm_subscription" "primary" {
//}
//
//resource "azurerm_role_assignment" "main" {
//  scope              = "${data.azurerm_subscription.primary.id}"
////  role_definition_id = data.azurerm_role_definition.main[0].id
//  role_definition_name = "Contributor"
//  principal_id       = "${azuread_service_principal.sp.id}"
//}

