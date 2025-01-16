provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "devopsshack-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "devopsshack-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  count               = 2
  name                = "devopsshack-subnet-${count.index}"
  resource_group_name = azurerm_resource_group.example.name
  virtual_network_name= azurerm_virtual_network.example.name
  address_prefixes    = ["10.0.${count.index}.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "devopsshack-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example" {
  count                       = 2
  name                        = "allow_inbound_ssh${count.index}"
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_public_ip" "example" {
  count               = 2
  name                = "devopsshack-public-ip-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  count               = 2
  name                = "devopsshack-nic-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(azurerm_subnet.example, count.index).id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.example, count.index).id
  }
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "devopsshack-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
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

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_kubernetes_cluster.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
}

