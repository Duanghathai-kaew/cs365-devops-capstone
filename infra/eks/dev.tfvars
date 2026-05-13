env        = "dev"
aws_region = "us-east-1"

vpc_cidr_block   = "10.16.0.0/16"
vpc_name         = "vpc"
igw_name         = "igw"
pub_subnet_count = 3
pub_cidr_block   = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
# NOTE: For AWS Learner Lab, verify that these AZs are available
# If terraform apply fails with AZ errors, update these values to match your lab's available AZs
# You can list available AZs with: aws ec2 describe-availability-zones --query 'AvailabilityZones[*].ZoneName'
pub_availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
pub_sub_name          = "subnet-public"
pri_subnet_count      = 3
pri_cidr_block        = ["10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20"]
pri_availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
pri_sub_name          = "subnet-private"
public_rt_name        = "public-route-table"
private_rt_name       = "private-route-table"
eip_name              = "elasticip-ngw"
ngw_name              = "ngw"
eks_sg                = "eks-sg"

# EKS
is_eks_cluster_enabled     = true
cluster_version            = "1.33"
cluster_name               = "eks-cluster"
endpoint_private_access    = true
endpoint_public_access     = true
ondemand_instance_types    = ["t3a.medium"]
spot_instance_types        = ["c5a.large", "c5a.xlarge", "m5a.large", "m5a.xlarge", "c5.large", "m5.large", "t3a.large", "t3a.xlarge", "t3a.medium"]
desired_capacity_on_demand = 1
min_capacity_on_demand     = 1
max_capacity_on_demand     = 5
desired_capacity_spot      = 1
min_capacity_spot          = 1
max_capacity_spot          = 10
addons = [
  {
    name    = "vpc-cni",
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
  # Add more addons as needed
]
