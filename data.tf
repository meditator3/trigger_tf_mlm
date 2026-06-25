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
# read current alb address from existing alb(deployed via helm of the app)
data "kubernetes_ingress_v1" "mlm" {
  metadata {
    name      = "mlm-ingress"
    namespace = "production"
  }
  depends_on = [helm_release.mlm-test]
}

# wait until dns for alb is provisioned
resource "time_sleep" "wait_for_alb_dns" {
  create_duration = "150s"
  depends_on = [data.kubernetes_ingress_v1.mlm]
}
# gets address of alb
data "dns_a_record_set" "alb" {
  host       = data.kubernetes_ingress_v1.mlm.status[0].load_balancer[0].ingress[0].hostname
  depends_on = [time_sleep.wait_for_alb_dns]
}