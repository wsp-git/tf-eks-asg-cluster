terraform {
  required_version = ">= 0.13"

  required_providers {
    aws        = ">= 3.40.0"
    kubernetes = "~> 2.0"
  }
}

provider "aws" {
  region = var.region
  #  access_key = ""
  #  secret_key = ""
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}