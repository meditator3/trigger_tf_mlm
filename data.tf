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
# wait loop for alb propegation on windows shell
# resource "null_resource" "wait_for_alb_loop" {
#   depends_on = [
#     helm_release.mlm-test,
#     helm_release.lb_controller,
#     kubernetes_service_account_v1.lb_controller
#   ]

#   provisioner "local-exec" {
#     # This explicitly forces Terraform to use PowerShell on Windows
#     interpreter = ["PowerShell", "-Command"]
    
#     command = <<HN
#         aws eks update-kubeconfig --region us-east-2 --name production-eks-mlm
#         Write-Host "Checking Ingress details..."
        
#         for ($i = 1; $i -le 30; $i++) {
#             # 1. Fetch raw json text stream and parse it
#             $jsonText = (kubectl get ingress mlm-ingress -n production -o json | Out-String)
#             $rawJson = ConvertFrom-Json $jsonText
            
#             $hostname = $null
            
#             # 2. Defensively check every layer of the K8s status object
#             if ($rawJson.status -and $rawJson.status.loadBalancer -and $rawJson.status.loadBalancer.ingress) {
#                 $hostname = $rawJson.status.loadBalancer.ingress[0].hostname
#             }
            
#             if ($hostname) {
#                 Write-Host "Success! ALB Address found: $hostname"
#                 exit 0
#             }
            
#             Write-Host "ALB field empty in K8s state. Retrying... (Attempt $i/30)"
#             Start-Sleep -Seconds 10
#         }
#         Write-Host "Error: Timed out waiting for ALB."
#         exit 1
#   HN
#   }
# }
# for linux
resource "null_resource" "wait_for_alb_loop" {
  depends_on = [
    helm_release.mlm-test,
    kubernetes_service_account_v1.lb_controller
  ]
  #forceful loop to  wait until dns for alb is provisioned, to get ip
    provisioner "local-exec" {
        # Force Linux shell interpretation
        interpreter = ["/bin/bash", "-c"]

        command = <<EOT
          aws eks update-kubeconfig --region us-east-2 --name production-eks-mlm
          echo "Waiting for AWS ALB to be created..."
          
          for i in {1..40}; do
            # FIXED: camelCase 'loadBalancer' required for raw jsonpath parsing on Linux
            HOSTNAME=$(kubectl get ingress mlm-ingress -n production -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
            
            if [ -n "$HOSTNAME" ]; then
              echo "Success! ALB Address found: $HOSTNAME .. now verifying DNS resolution"
              if nslookup "$HOSTNAME" >/dev/null 2>&1 || host "$HOSTNAME" >/dev/null 2>&1; then
                echo "Success! ALB DNS is active and resolvable."
                exit 0
              fi
              echo "Hostname exists but DNS is not propagated yet..."
            fi

            echo "ALB not ready yet. Retrying in 15 seconds... (Attempt $i/40)"
            sleep 15
          done
          
          echo "Error: Timed out waiting for ALB after 5 minutes."
          exit 1
        EOT
      }
}


# read current alb address from existing alb(deployed via helm of the app)
data "kubernetes_ingress_v1" "mlm" {
  metadata {
    name      = "mlm-ingress"
    namespace = "production"
  }
  depends_on = [null_resource.wait_for_alb_loop]
  
  
}



# gets address of alb
data "dns_a_record_set" "alb" {
  host       = data.kubernetes_ingress_v1.mlm.status[0].load_balancer[0].ingress[0].hostname
}