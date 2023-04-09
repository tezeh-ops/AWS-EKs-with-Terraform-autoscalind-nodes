resource "aws_iam_role" "nodes" {
  name               = "eks-node-group-nodes"
  assume_role_policy = data.aws_iam_policy_document.nodes.json   # here the nodes are asuming the policies we created
}

# Attaching 3 policies to our nodes 
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# CREating our Nodes Group and we will be placing them in our private subnet
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
      #aws_subnet.public[0].id,aws_subnet.public[1].id,
      aws_subnet.private[0].id, aws_subnet.private[1].id  # we are choosing private here to place our nodes
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {     # our scaling confuguration
    desired_size = 2
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1  
  }

  labels = {     # placing this label on our nodes in case we need it for taint or Nodeselector
    role = "general"   
  }

  tags = {    # NB we most tag our node. Because without this tags our Autoscaler will not be able to determine or find the node its need to manage
    "k8s.io/cluster-autoscaler/demo"    = "owned"
    "k8s.io/cluster-autoscaler/enabled" = true
  }
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
  ]
}
