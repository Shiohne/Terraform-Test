# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.company_initials}-rg-prod"
  location = var.location
  tags = {
    Team = "Cloud Integration"
  }
}

resource "azurerm_resource_group" "rg-vms" {
  name     = "${var.company_initials}-rg-prod-vms"
  location = var.location
  tags = {
    Team = "Cloud Integration"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.company_initials}-vnet-01"
  address_space       = ["172.16.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Team = "Cloud Integration"
  }

}

resource "azurerm_subnet" "sub1" {
  name                 = "${var.company_initials}-sub-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.1.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies = false
}

resource "azurerm_subnet" "sub2" {
  name                 = "${var.company_initials}-sub-02"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.2.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies = false
}

resource "azurerm_subnet" "sub3" {
  name                 = "${var.company_initials}-sub-03"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.3.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies = false
}

resource "azurerm_network_security_group" "nsg_priv" {
  name                = "${var.company_initials}-nsg-priv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Team = "Cloud Integration"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_priv_sub1" {
  subnet_id                 = azurerm_subnet.sub1.id
  network_security_group_id = azurerm_network_security_group.nsg_priv.id
}


resource "azurerm_subnet_network_security_group_association" "nsg_priv_sub2" {
  subnet_id                 = azurerm_subnet.sub2.id
  network_security_group_id = azurerm_network_security_group.nsg_priv.id
}

resource "azurerm_network_security_group" "nsg_pub" {
  name                = "${var.company_initials}-nsg-pub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Team = "Cloud Integration"
  }
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "AllowAnyRDPInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_pub.name

}

resource "azurerm_subnet_network_security_group_association" "nsg_pub_sub3" {
  subnet_id                 = azurerm_subnet.sub3.id
  network_security_group_id = azurerm_network_security_group.nsg_pub.id
}
