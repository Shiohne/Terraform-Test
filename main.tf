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
    Team = "Cloud"
  }
}

resource "azurerm_resource_group" "rg-vms" {
  name     = "${var.company_initials}-rg-prod-vms"
  location = var.location
  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.company_initials}-vnet-01"
  address_space       = ["172.16.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Team = "Cloud"
  }

}

resource "azurerm_subnet" "sub1" {
  name                                           = "${var.company_initials}-sub-01"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["172.16.1.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
}

resource "azurerm_subnet" "sub2" {
  name                                           = "${var.company_initials}-sub-02"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["172.16.2.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
}

resource "azurerm_subnet" "sub3" {
  name                                           = "${var.company_initials}-sub-03"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["172.16.3.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
}

resource "azurerm_network_security_group" "nsg_priv" {
  name                = "${var.company_initials}-nsg-priv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Team = "Cloud"
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
    Team = "Cloud"
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

resource "azurerm_public_ip" "pub_ip" {
  name                = "${var.company_initials}-natgw-pubip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_nat_gateway" "natgw" {
  name                = "${var.company_initials}-natgw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"

  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "pubip_nat_association" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.pub_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "sub1_nat_association" {
  subnet_id      = azurerm_subnet.sub1.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "sub2_nat_association" {
  subnet_id      = azurerm_subnet.sub2.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_public_ip" "bastion_pub_ip" {
  name                = "${var.company_initials}-bastion-pubip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vms.name
  allocation_method   = "Static"

  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.company_initials}-bastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vms.name

  ip_configuration {
    name                          = "${var.company_initials}-ipconfig"
    subnet_id                     = azurerm_subnet.sub3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pub_ip.id
  }

  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_windows_virtual_machine" "bastion" {
  name                     = "${var.company_initials}-bastion"
  location                 = var.location
  admin_username           = "terraform-admin"
  admin_password           = var.password
  resource_group_name      = azurerm_resource_group.rg-vms.name
  network_interface_ids    = [azurerm_network_interface.bastion_nic.id]
  size                     = "Standard_B2s"
  enable_automatic_updates = true

  os_disk {
    name                 = "${var.company_initials}-bastion-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_network_interface" "dc_nic" {
  name                = "${var.company_initials}-dc-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vms.name

  ip_configuration {
    name                          = "${var.company_initials}-ipconfig"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.1.10"
  }

  tags = {
    Team = "Cloud"
  }
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                     = "${var.company_initials}-dc"
  location                 = var.location
  admin_username           = "terraform-admin"
  admin_password           = var.password
  resource_group_name      = azurerm_resource_group.rg-vms.name
  network_interface_ids    = [azurerm_network_interface.dc_nic.id]
  size                     = "Standard_B2s"
  enable_automatic_updates = true

  os_disk {
    name                 = "${var.company_initials}-dc-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = {
    Team = "Cloud"
  }
}
