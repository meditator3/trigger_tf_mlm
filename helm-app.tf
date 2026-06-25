resource "helm_release" "mlm-test" {
    name        = "mlm-test"
    chart       = "./helm-mlm/mlm-test"
    depends_on  = [
        aws_eks_cluster.this,
        aws_eks_node_group.this
    ]
}