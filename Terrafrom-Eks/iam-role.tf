resource "aws_iam_role" "EKSCluster_role" {
  name = "EKSClusterRole"
  assume_role_policy = jsondecode({
    version = "2012-10-17"
    statement = [
        {
            action = "sts:AssumeRole"
            effect = "Allow"
            principal = {
                service = "eks.amazonaws.com"
            }
        },
    ]
  })
}

resource "aws_iam_role" "NodeGroupRole" {
  name = "EKSNodeGroupRole"
  assume_role_policy = jsondecode({
    version = "2012-10-17"
    statement = [
        {
            action = "sts:AssumeRole"
            effect = "Allow"
            principal = {
                service = "ec2.amazonaws.com"
            }
        },
    ]
  })    
}