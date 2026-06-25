resource "kubernetes_namespace_v1" "production" {
  metadata {
    name = "production"
  }
}