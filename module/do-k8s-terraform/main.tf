resource "digitalocean_kubernetes_cluster" "training" {
  name   = var.cluster_name
  region = var.region
  auto_upgrade = false
  version = var.cluster_version

  node_pool {
    name       = var.node_pool_name
    size       = var.node_size
    auto_scale = true
    min_nodes  = var.min_nodes_count
    max_nodes  = var.max_nodes_count
  }
}
