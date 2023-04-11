variable "do_token" {}

variable "cluster_name" {
  type        = string
  default     = "training"
  description = "Cluster name"
}

variable "cluster_version" {
  type = string
  default = "1.26.3-do.0"
  description = "Cluster version"
}

variable "region" {
  type        = string
  default     = "sgp1"
  description = "Region in which cluster will sit"
}

variable "node_pool_name" {
  type        = string
  default     = "autoscale-worker-pool"
  description = "worker node pool name"
}

variable "node_size" {
  type        = string
  default     = "s-2vcpu-2gb"
  description = "node size"
}

variable "min_nodes_count" {
  type = number
  default = 1
  description = "Minimun node count for autoscale worker group"
}

variable "max_nodes_count" {
  type = number
  default = 2
  description = "Maximum node count for autoscale worker group"
}
