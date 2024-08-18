terraform {
  required_version = ">= 1.0"
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = "1.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
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
  depends_on = [ rke_cluster.foo ]
}

provider "kubernetes" {
  config_path = local_sensitive_file.kube_cluster_yaml.filename
}

resource "kubernetes_namespace" "kiratech_test" {
  metadata {
    name = "kiratech-test"
  }

  depends_on = [ rke_cluster.foo ]
}

resource "kubernetes_namespace" "cis_operator_system" {
  metadata {
    name = "cis-operator-system"
  }

  depends_on = [ rke_cluster.foo ]
}

provider "helm" {
  kubernetes {
    config_path = local_sensitive_file.kube_cluster_yaml.filename
  }  
}

resource "helm_release" "rancher_cis_benchmark_crds" {
  name       = "rancher-cis-benchmark-crd"
  namespace  = "kube-system"
  chart      = "rancher-cis-benchmark-crd"
  repository = "https://charts.rancher.io"
  version    = "5.2.0"

  depends_on = [ kubernetes_namespace.cis_operator_system ]
}

resource "helm_release" "rancher_cis_benchmark" {
  name       = "rancher-cis-benchmark"
  namespace  = "cis-operator-system"
  chart      = "rancher-cis-benchmark"
  repository = "https://charts.rancher.io"
  version    = "5.2.0"

  depends_on = [ helm_release.rancher_cis_benchmark_crds ]
}

provider "kubectl" {
  config_path = local_sensitive_file.kube_cluster_yaml.filename
}

resource "kubectl_manifest" "cis_scan" {
  yaml_body = <<YAML
apiVersion: cis.cattle.io/v1
kind: ClusterScan
metadata:
  name: rke-cis-scan
spec:
  scanProfileName: rke-profile-permissive-1.8
YAML
  
    depends_on = [helm_release.rancher_cis_benchmark]
  }

data "kubectl_path_documents" "kube_bench_remote" {
  pattern = "./terraform/manifests/*.yaml"
}

resource "kubectl_manifest" "kube_bench_remote" {
  for_each  = toset(data.kubectl_path_documents.kube_bench_remote.documents)
  yaml_body = each.value
  depends_on = [kubectl_manifest.cis_scan]
}
