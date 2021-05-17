data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = ["602401143452"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.19*"]
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  cluster_name                  = "tz-eks-cluster-1705v1"
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"
}

resource "aws_security_group" "wkgroup_main" {
  name_prefix = "workers_eks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.ingress_cidr
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0.0"

  name = "tz-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    CreatedByTerraform = "true"
    Environment        = "test-task-eks"
  }

}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  tags = {
    Environment = "test-task-eks"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "tz-eks-worker-group-1"
      instance_type                 = var.instance_type
      asg_min_size                  = var.asg_min_size
      asg_max_size                  = var.asg_max_size
      additional_security_group_ids = [aws_security_group.wkgroup_main.id]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]

}

resource "helm_release" "cluster_autoscale" {
  name       = "autoscaler"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  namespace  = "kube-system"
  # version    = ""

  values = [
    "${file("cluster-autoscaler-chart-values.yaml")}"
  ]

  depends_on = [
    module.eks
  ]
}
