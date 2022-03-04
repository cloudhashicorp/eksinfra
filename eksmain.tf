resource "aws_iam_role" "eksclusterrole" {
  name = "darwin-eks-cluster-role"

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

resource "aws_iam_role_policy_attachment" "darwin-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksclusterrole.name
}

#EKS Cluster

resource "aws_eks_cluster" "ekscluster" {
  name     = "darwinekscluster"
  role_arn = aws_iam_role.eksclusterrole.arn

  vpc_config {
    subnet_ids = [(var.outrubriccloudappprisub[0]), (var.outrubriccloudappprisub[1])]
    #subnet_ids = [(var.outrubriccloudapppubsub[0]), (var.outrubriccloudapppubsub[1])]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  //   depends_on = [
  //     aws_iam_role_policy_attachment.darwin-AmazonEKSClusterPolicy
  //   ]
}


####################################################
//EKS Node Group

resource "aws_iam_role" "eksnoderole" {
  name = "darwin-eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "darwin-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eksnoderole.name
}

resource "aws_iam_role_policy_attachment" "darwin-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eksnoderole.name
}

resource "aws_iam_role_policy_attachment" "darwin-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eksnoderole.name
}


#Node Group

resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.ekscluster.name
  node_group_name = "darwin-node-group"
  node_role_arn   = aws_iam_role.eksnoderole.arn
  #subnet_ids      = [(var.outrubriccloudappprisub[0]), (var.outrubriccloudappprisub[1])]
  subnet_ids      = [(var.outrubriccloudapppubsub[0]), (var.outrubriccloudapppubsub[1])]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 2
  }

  force_update_version = false

  labels = {
    role = "darwin-node-group"
  }

  remote_access {

    ec2_ssh_key = var.outmyec2key

  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.darwin-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.darwin-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.darwin-AmazonEC2ContainerRegistryReadOnly,
  ]
}
