terraform {
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = "1.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

provider "rke" {
  log_file = "rke_debug.log"
}

resource "rke_cluster" "foo" {
  cluster_yaml = file("${path.root}/terraform/cluster.yaml")
}

resource "local_sensitive_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = rke_cluster.foo.kube_config_yaml
}

provider "kubernetes" {
  config_path = local_sensitive_file.kube_cluster_yaml.filename
}

resource "kubernetes_namespace" "kiratech_test" {
  metadata {
    name = "kiratech-test"
  }
}

resource "kubernetes_pod" "kube_bench" {
  metadata {
    name      = "kube-bench"
    namespace = kubernetes_namespace.kiratech_test.metadata[0].name
  }
  spec {
    container {
      name    = "kube-bench"
      image   = "aquasec/kube-bench:latest"
      command = ["kube-bench", "--json"]
    }
  }
}
