# This snippet creats a VM and attach a system-assigned identity and a User-assigned identiy to it.
# This needs a storage account to be created (example in blob_storage component).
provider "azurerm" {
  version  = "~> 2.3"
  features = {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "hemant-test-resources"
  location = "West Europe"
}

# Create a private network
resource "azurerm_virtual_network" "main" {
  name                = "hemant-testing-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                = "hemant-test-public-ip"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "external" {
  name                = "external-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "external"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_network_security_group" "allow_ssh" {
  name                = "allow_ssh"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "${azurerm_network_interface.external.private_ip_address}"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = "${azurerm_network_interface.external.id}"
  network_security_group_id = "${azurerm_network_security_group.allow_ssh.id}"
}

# Start creating the VM now.
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "hemant-test-machine"
  admin_username      = "ubuntu"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  size                = "Standard_F2"

  network_interface_ids = [
    "${azurerm_network_interface.external.id}", # first one is the primary network interface.
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = "${file("~/.ssh/hdev.pub")}" # My public key for now.
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type         = "SystemAssigned, UserAssigned"         # SystemAssigned | UserAssigned | SystemAssigned, UserAssigned
    # A list of User Managed Identity ID's in case of UserAssigned
    identity_ids = [
      "${azurerm_user_assigned_identity.storage_access.id}"
    ]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

### Assign the role to the identity.
resource "azurerm_role_assignment" "access_susbcription_role" {
  scope = "${azurerm_resource_group.rg.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azurerm_linux_virtual_machine.vm.identity.0.principal_id}" # 0 is the system managed Identity
}

##### User defined identiy
resource "azurerm_user_assigned_identity" "storage_access" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  name = "storage-access"
}

# this is the ID of storage account created in blob_store component `storage_account_id`
variable "storage_account" {
  default = "/subscriptions/<subscription_id>/resourceGroups/hemant-test-storage/providers/Microsoft.Storage/storageAccounts/hemantstorageaccount"
}

resource "azurerm_role_definition" "storage_role" {
  name  = "storage_access_role"
  scope = "${var.storage_account}"

  permissions {
    # Actions are documented here https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations#microsoftstorage
    actions     = [
      "Microsoft.Storage/storageAccounts/listKeys/action",
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
    ]
    not_actions = []
  }

  assignable_scopes = [
    "${var.storage_account}",
  ]
}

resource "azurerm_role_assignment" "example" {
  scope              = "${var.storage_account}"
  role_definition_id = "${azurerm_role_definition.storage_role.id}"
  principal_id       = "${azurerm_user_assigned_identity.storage_access.principal_id}"
}
