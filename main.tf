terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "1.5.0"
    }
  }
}

provider "rke" {
    log_file = "rke_debug.log"
}

# Create a new RKE cluster using config yaml
resource "rke_cluster" "foo" {
  cluster_yaml = file("terraform/cluster.yaml")
}