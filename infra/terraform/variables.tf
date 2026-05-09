variable "project_name" {
  description = "Project/resource naming prefix"
  type        = string
  default     = "url-shortner"
}

variable "aws_region" {
  description = "AWS region where backend resources are deployed"
  type        = string
  default     = "us-east-1"
}

variable "root_domain" {
  description = "Root DNS domain already hosted in Route53"
  type        = string
  default     = "jkrocha.com.br"
}

variable "api_subdomain" {
  description = "API subdomain name"
  type        = string
  default     = "api"
}

variable "frontend_subdomain" {
  description = "Frontend subdomain name"
  type        = string
  default     = "shortner"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the root domain"
  type        = string
}

variable "api_certificate_arn" {
  description = "ACM certificate ARN for api.<domain> (regional certificate in backend region)"
  type        = string
}

variable "frontend_certificate_arn" {
  description = "ACM certificate ARN for frontend domain (must be in us-east-1 for CloudFront)"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "url-shortner"
}

variable "lambda_zip_path" {
  description = "Path to the packaged backend Lambda zip file"
  type        = string
  default     = "../artifacts/url-shortner-backend.zip"
}

variable "frontend_bucket_name" {
  description = "Globally unique S3 bucket name for frontend static files"
  type        = string
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "prod"
}
