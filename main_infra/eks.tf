module "vpc" {
    source       = "./vpc"
}

resource "aws_eks_cluster" "this" {
    name          = var.CLUSTER_NAME
    role_arn      = aws_iam_role.cluster.arn

    vpc_config {
        subnet_ids              = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
        endpoint_private_access = true
        endpoint_public_access  = true
    }
}
# identity providers for cert - what allows ServiceAccounts to assume IAM roles
data "tls_certificate" "eks" {
    url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# the connector of oidc
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_eks_node_group" "this" {
    cluster_name    = aws_eks_cluster.this.name
    node_group_name = "mlm-nodes"
    node_role_arn   = aws_iam_role.nodes.arn
    subnet_ids      = module.vpc.private_subnet_ids

    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 0
    }

    instance_types = [var.INSTANCE_TYPE]
}