locals {
  cluster_name = var.cluster_name
}

# Use the provided LabRole from the AWS Academy Learner Lab environment
data "aws_iam_role" "labrole" {
  name = "LabRole"
}
