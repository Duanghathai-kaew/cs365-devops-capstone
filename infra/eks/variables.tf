variable "aws_region" {
  default = "us-east-1"
}

variable "env" {
  default = "dev"
}

variable "cluster_name" {
  default = "eks-cluster"
}

variable "vpc_cidr_block" {
  default = "10.16.0.0/16"
}

variable "vpc_name" {
  default = "vpc"
}

variable "igw_name" {
  default = "igw"
}

variable "pub_subnet_count" {
  default = 3
}

variable "pub_cidr_block" {
  type    = list(string)
  default = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
}

variable "pub_availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "pub_sub_name" {
  default = "subnet-public"
}

variable "pri_subnet_count" {
  default = 3
}

variable "pri_cidr_block" {
  type    = list(string)
  default = ["10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20"]
}

variable "pri_availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "pri_sub_name" {
  default = "subnet-private"
}

variable "public_rt_name" {
  default = "public-route-table"
}

variable "private_rt_name" {
  default = "private-route-table"
}

variable "eip_name" {
  default = "elasticip-ngw"
}

variable "ngw_name" {
  default = "ngw"
}

variable "eks_sg" {
  default = "eks-sg"
}

# EKS
variable "is_eks_cluster_enabled" {
  default = true
}

variable "cluster_version" {
  default = "1.33"
}

variable "endpoint_private_access" {
  default = true
}

variable "endpoint_public_access" {
  default = true
}

variable "ondemand_instance_types" {
  type    = list(string)
  default = ["t3a.medium"]
}

variable "spot_instance_types" {
  type    = list(string)
  default = ["c5a.large", "c5a.xlarge", "m5a.large", "m5a.xlarge", "c5.large", "m5.large", "t3a.large", "t3a.xlarge", "t3a.medium"]
}

variable "desired_capacity_on_demand" {
  default = 1
}

variable "min_capacity_on_demand" {
  default = 1
}

variable "max_capacity_on_demand" {
  default = 5
}

variable "desired_capacity_spot" {
  default = 1
}

variable "min_capacity_spot" {
  default = 1
}

variable "max_capacity_spot" {
  default = 10
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "vpc-cni"
      version = "v1.20.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.12.2-eksbuild.4"
    },
    {
      name    = "kube-proxy"
      version = "v1.33.0-eksbuild.2"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.46.0-eksbuild.1"
    }
  ]
}