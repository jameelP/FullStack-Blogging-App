provider "azurerm" {
  features {}
  subscription_id = "000000-000000-0000000-0000000"
}

resource "azurerm_resource_group" "devops_rg" {
  name     = "devops-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "devops_vnet" {
  name                = "devops-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
}

resource "azurerm_subnet" "devops_subnet" {
  count               = 2
  name                = "devops-subnet-${count.index}"
  resource_group_name = azurerm_resource_group.devops_rg.name
  virtual_network_name= azurerm_virtual_network.devops_vnet.name
  address_prefixes    = ["10.0.${count.index}.0/24"]
}

resource "azurerm_network_security_group" "devops_nsg" {
  name                = "devops-nsg"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
}

resource "azurerm_network_security_rule" "devops_nsg_rule" {
  name                        = "allow_inbound_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.devops_rg.name
  network_security_group_name = azurerm_network_security_group.devops_nsg.name
}

resource "azurerm_public_ip" "devops_pip" {
  count               = 2
  name                = "devops-public-ip-${count.index}"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "devops_nic" {
  count               = 2
  name                = "devops-nic-${count.index}"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(azurerm_subnet.devops_subnet, count.index).id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.devops_pip, count.index).id
  }
}

resource "azurerm_kubernetes_cluster" "devops_aks" {
  name                = "devopsshack-cluster"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  dns_prefix          = "devopsshack"

  default_node_pool {
    name       = "devopsshack"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "devops_role_assignment" {
  scope                = azurerm_kubernetes_cluster.devops_aks.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.devops_aks.kubelet_identity[0].object_id
}
