data "aws_eks_cluster_auth" "this" {
    name = aws_eks_cluster.this.name
}


data "http" "lb_controller_policy" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

data "aws_iam_policy_document" "lb_controller_assume" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect  = "Allow"
        # strip https for expected id provider value, ? variable == values
        # condition that only this specific LB gets the oicd token
        condition {
            test     = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
            values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
        }
        # who is allowed(3rd party in this case)
        principals {
            identifiers = [aws_iam_openid_connect_provider.eks.arn]
            type        = "Federated"
        }
    }
}
