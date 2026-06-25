variable "AWS_REGION" {
    description = "region"
    default = "us-east-2"
}

variable "AMI" {
    description = "image for linux 2023"
    default = "ami-068e51c52307622af"
}

variable "INSTANCE_TYPE" {
    description = "instance power"
    default = "t3.medium"
}


variable "CLUSTER_NAME" {
    default = "production-eks-mlm"
}

