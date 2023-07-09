variable "name" {
  description = "App Name"
  type        = string
  default     = "qiita-trend-line-bot-2"
}

# VPC
variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "qiita-trend-line-bot-cluster-2"
}