output "id" {
  value = digitalocean_kubernetes_cluster.training.name
}

output "endpoint" {
  value = digitalocean_kubernetes_cluster.training.endpoint
}

output "kube_config" {
  value = digitalocean_kubernetes_cluster.training.kube_config
  sensitive = true
}
