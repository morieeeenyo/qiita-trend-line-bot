##############################
# IAM Role for EKS Cluster
# ここではeksクラスターに信頼関係を結ぶロールを作成する
# AmazonEKSClusterPolicyとAmazonEKSServicePolicyをロールにアタッチする
##############################
resource "aws_iam_role" "eks_iam_role" {
  name = "eks-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_iam_role.name
}

##############################
# EKS Cluster
##############################
resource "aws_eks_cluster" "eks" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks_iam_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy
  ]
}

##############################
# IAM Role for EKS Node Group
# ここではeksノード用のロールを作成し、AmazonEKSWorkerNodePolicyとAmazonEKS_CNI_Policy,AmazonEC2ContainerRegistryReadOnlyポリシーをアタッチする
##############################
resource "aws_iam_role" "eks_node_group_iam_role" {
  name = "eks-node-group-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_iam_role.name
}

##############################
# EKS Node Group
# 今回はFargetではなくEC2を利用する
##############################
resource "aws_eks_node_group" "eks_ng" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-ng"
  node_role_arn   = aws_iam_role.eks_node_group_iam_role.arn
  subnet_ids      = aws_subnet.public.*.id
  instance_types  = ["t2.small"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly
  ]
}
