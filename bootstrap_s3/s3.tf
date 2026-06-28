resource "aws_s3_bucket" "mlm-tf-state" {
    bucket = "mlm-tf-state"

    tags = {
        Name         = "mlm-tf-state"
        Managed_by   = "terraform"
    }
}