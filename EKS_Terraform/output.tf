output "resource_group_name" {
  value = azurerm_resource_group.devops_rg.name
}

output "kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.devops_aks.id
}

output "subnet_ids" {
  value = azurerm_subnet.devops_subnet[*].id
}
