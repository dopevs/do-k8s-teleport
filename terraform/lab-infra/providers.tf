terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
  }
}

provider "null" {
}

# Configure the Helm provider
provider "helm" {
  kubernetes {
    host  = module.do_k8s_terraform.endpoint
    token = module.do_k8s_terraform.kube_config[0].token
    cluster_ca_certificate = base64decode(
      module.do_k8s_terraform.kube_config[0].cluster_ca_certificate
    )
  }
}

# Configure the kubernetes provider
provider "kubernetes" {
  host  = module.do_k8s_terraform.endpoint
  token = module.do_k8s_terraform.kube_config[0].token
  cluster_ca_certificate = base64decode(
    module.do_k8s_terraform.kube_config[0].cluster_ca_certificate
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", module.do_k8s_terraform.id]
  }
}

