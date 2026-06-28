variable "VPC_CIDR" {
    default = "10.0.0.0/16"    
}

variable "PUBLIC_SUBNETS" {
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "PRIVATE_SUBNETS" {
    default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "AVAILABILITY_ZONE" {
    default = ["us-east-2a", "us-east-2b"]
}

variable "CLUSTER_NAME" {
    default = "production-eks-mlm"
}

