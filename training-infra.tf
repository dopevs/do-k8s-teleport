locals {
  helm_values_dir = "${path.root}/helm-values"
  k8s_manifests_dir = "${path.root}/k8s-manifests"
}

module "do_k8s_terraform" {
  source = "./module/do-k8s-terraform"
  
  do_token = var.do_token
  cluster_name = "training"
  cluster_version = "1.26.3-do.0"
  region = "sgp1"
  node_pool_name = "autoscale-worker-nodepool"
  node_size = "s-2vcpu-2gb"
  min_nodes_count = 2
  max_nodes_count = 5
}

# Install Traefik using Helm
resource "helm_release" "traefik" {
  name             = "traefik"
  namespace        = "traefik"
  create_namespace = true
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "22.1.0"

  # Pass the values file
  values = [file("${local.helm_values_dir}/treafik/values.yaml")]
  depends_on = [
    module.do_k8s_terraform
  ]
}

# Install Cert Manager with Helm
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.7.0"

  # Pass the values file
  values = [file("${local.helm_values_dir}/cert-manager/values.yaml")]
  depends_on = [
    module.do_k8s_terraform
  ]
}

resource "kubernetes_manifest" "cf_api_token" {
  manifest = yamldecode(file("${local.k8s_manifests_dir}/cert-manager/secrets/cloudflare-api-token.yaml"))
  depends_on = [
    module.do_k8s_terraform,
    helm_release.cert_manager
  ]
}

resource "kubernetes_manifest" "issuer_prod" {
  manifest = yamldecode(file("${local.k8s_manifests_dir}/cert-manager/cluster-issuer.yaml"))
  depends_on = [
    module.do_k8s_terraform,
    helm_release.cert_manager
  ]
}
