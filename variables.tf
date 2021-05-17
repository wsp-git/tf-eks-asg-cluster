variable "region" {
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t3.small"
}

variable "cluster_version" {
  default = "1.19"
}

variable "asg_min_size" {
  default = "1"
}

variable "asg_max_size" {
  default = "3"
}

variable "ingress_cidr" {
  type    = list(any)
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
