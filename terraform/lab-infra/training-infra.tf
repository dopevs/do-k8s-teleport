locals {
  helm_values_dir = "../../helm-values"
  k8s_manifests_dir = "../../k8s-manifests"
}

module "do_k8s_terraform" {
  source = "../module/do-k8s-terraform"
  
  do_token = var.do_token
  cluster_name = "training"
  cluster_version = "1.26.5-do.0"
  region = "sgp1"
  node_pool_name = "autoscale-worker-nodepool"
  node_size = "s-2vcpu-2gb"
  min_nodes_count = 2
  max_nodes_count = 5
}

# wait until cluster is ready
resource "null_resource" "api_health_check" {
  provisioner "local-exec" {
    command = "until curl --output /dev/null --silent --fail --insecure ${module.do_k8s_terraform.endpoint}/healthz; do sleep 5; done"
  }
  depends_on = [ 
    module.do_k8s_terraform
  ]
}

# # Install Traefik using Helm
# resource "helm_release" "traefik" {
#   name             = "traefik"
#   namespace        = "traefik"
#   create_namespace = true
#   repository       = "https://traefik.github.io/charts"
#   chart            = "traefik"
#   version          = "22.1.0"

#   # Pass the values file
#   values = [file("${local.helm_values_dir}/treafik/values.yaml")]
#   depends_on = [
#     module.do_k8s_terraform,
#     null_resource.api_health_check
#   ]
# }

# # Install Cert Manager with Helm
# resource "helm_release" "cert_manager" {
#   name             = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   version          = "v1.7.0"

#   # Pass the values file
#   values = [file("${local.helm_values_dir}/cert-manager/values.yaml")]
#   depends_on = [
#     module.do_k8s_terraform,
#     null_resource.api_health_check
#   ]
# }

# resource "kubernetes_manifest" "cf_api_token" {
#   provider = kubernetes
#   manifest = yamldecode(file("${local.k8s_manifests_dir}/cert-manager/secrets/cloudflare-api-token.yaml"))
#   depends_on = [
#     module.do_k8s_terraform,
#     helm_release.cert_manager,
#     null_resource.api_health_check
#   ]
# }

# resource "kubernetes_manifest" "issuer_prod" {
#   provider = kubernetes
#   manifest = yamldecode(file("${local.k8s_manifests_dir}/cert-manager/cluster-issuer.yaml"))
#   depends_on = [
#     module.do_k8s_terraform,
#     helm_release.cert_manager,
#     kubernetes_manifest.cf_api_token,
#     null_resource.api_health_check
#   ]
# }

# Install teleport cluster with Helm
resource "helm_release" "teleport_cluster" {
  name             = "teleport-cluster"
  namespace        = "teleport-cluster"
  create_namespace = true
  repository       = "https://charts.releases.teleport.dev"
  chart            = "teleport-cluster"
  version          = "13.1.0"

  # Pass the values file
  values = [file("${local.helm_values_dir}/teleport-cluster/values.yaml")]
  depends_on = [
    module.do_k8s_terraform,
    null_resource.api_health_check,
  ]
}

# Install teleport kube agent with Helm
resource "helm_release" "teleport_kube_agent" {
  name             = "teleport-kube-agent"
  namespace        = "teleport-kube-agent"
  create_namespace = true
  repository       = "https://charts.releases.teleport.dev"
  chart            = "teleport-kube-agent"
  version          = "13.1.0"

  # Pass the values file
  values = [file("${local.helm_values_dir}/teleport-kube-agent/values.yaml")]
  depends_on = [
    module.do_k8s_terraform,
    null_resource.api_health_check,
    helm_release.teleport_cluster
  ]
}
