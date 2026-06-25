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

variable "image_tag" {
    type        = string
    description = "Last tag of container image injected from CI"
    default     = "746fa77226de9f54f114c7fbc79e48ccaa9e20ee" 
}