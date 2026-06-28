terraform {
    backend "s3" {
        bucket = "mlm-tf-state"
        key    = "terraform.tfstate"
        region = "us-east-2"
    }
}