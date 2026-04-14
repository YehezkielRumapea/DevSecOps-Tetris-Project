resource "aws_eks_node_group" "tetris-node-group" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  node_group_name = var.eksnode-group-name
  node_role_arn = aws_iam_role.NodeGroupRole.arn
  subnet_ids = [data.aws_subnet.subnet, aws_subnet.public_subnet2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1  
  }
  
  instance_types = ["t3a.medium"]
  disk_size = 20

  depends_on = [ 
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
   ]  
}