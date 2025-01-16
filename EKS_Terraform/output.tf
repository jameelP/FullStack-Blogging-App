output "resource_group_name" {
  value = azurerm_resource_group.example.name
}

output "kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.example.id
}

output "subnet_ids" {
  value = azurerm_subnet.example[*].id
}

