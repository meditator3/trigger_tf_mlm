
resource "aws_iam_role" "lb_controller" {
  name               = "${var.CLUSTER_NAME}-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume.json
}
resource "aws_iam_policy" "lb_controller" {
  name        = "${var.CLUSTER_NAME}-AWSLoadBalancerControllerIAMPolicy"
  description = "IAM Policy for AWS Load Balancer Controller"
  policy      = data.http.lb_controller_policy.response_body
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  policy_arn = aws_iam_policy.lb_controller.arn
  role       = aws_iam_role.lb_controller.name
}

resource "kubernetes_service_account_v1" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller.arn
    }
  }
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2" 

  set = [

   {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  },
  {
    name  = "serviceAccount.create"
    value = "false"
  },
   {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.lb_controller.metadata[0].name
  },
  
  {
    name  = "region"
    value = var.AWS_REGION
  },
   {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
  ]

  depends_on = [
    aws_eks_node_group.this,
    aws_iam_role_policy_attachment.lb_controller
  ]
}