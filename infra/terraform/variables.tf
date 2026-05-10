# =============================================================================
# variables.tf
# =============================================================================
# Declares all input variables for the URL Shortener infrastructure.
#
# Variables with a "default" can be overridden in terraform.tfvars.
# Variables without a "default" are required and must be supplied.
# =============================================================================

# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

# Prefix applied to every AWS resource name, making resources easily
# identifiable and avoiding naming collisions across projects.
variable "project_name" {
  description = "Project/resource naming prefix"
  type        = string
  default     = "url-shortner"
}

# AWS region where all backend resources (Lambda, DynamoDB, API Gateway)
# will be deployed. CloudFront is global; its ACM certificate must be
# in us-east-1 regardless of this value.
variable "aws_region" {
  description = "AWS region where backend resources are deployed"
  type        = string
  default     = "us-east-1"
}

# Environment label (e.g., "prod", "staging") applied to resource tags
# for cost allocation and operational visibility.
variable "environment" {
  description = "Environment label"
  type        = string
  default     = "prod"
}

# -----------------------------------------------------------------------------
# DNS and Domains
# -----------------------------------------------------------------------------

# Root domain already registered and hosted in Route53.
# Subdomains for the API and frontend will be created under this domain.
variable "root_domain" {
  description = "Root DNS domain already hosted in Route53"
  type        = string
  default     = "jkrocha.com.br"
}

# Subdomain for the API endpoint.
# Final URL: https://<api_subdomain>.<root_domain>
variable "api_subdomain" {
  description = "API subdomain name"
  type        = string
  default     = "api"
}

# Subdomain for the Angular frontend.
# Final URL: https://<frontend_subdomain>.<root_domain>
variable "frontend_subdomain" {
  description = "Frontend subdomain name"
  type        = string
  default     = "shortner"
}

# ID of the Route53 hosted zone for the root domain.
# Required to create DNS A alias records for the API and frontend.
variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the root domain"
  type        = string
}

# -----------------------------------------------------------------------------
# TLS Certificates (ACM)
# -----------------------------------------------------------------------------

# ARN of the ACM certificate for the API custom domain.
# Must be a REGIONAL certificate located in the same region as the API Gateway.
variable "api_certificate_arn" {
  description = "ACM certificate ARN for api.<domain> (regional certificate in backend region)"
  type        = string
}

# ARN of the ACM certificate for the frontend custom domain.
# MUST be in us-east-1, which is a hard requirement for CloudFront distributions.
variable "frontend_certificate_arn" {
  description = "ACM certificate ARN for frontend domain (must be in us-east-1 for CloudFront)"
  type        = string
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------

# Name of the DynamoDB table used to store short code -> original URL mappings.
variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "url-shortner"
}

# -----------------------------------------------------------------------------
# Compute
# -----------------------------------------------------------------------------

# Path to the packaged Spring Boot JAR/ZIP artifact that will be deployed
# as a Lambda function. Run `mvn package` in the backend directory to generate it.
variable "lambda_zip_path" {
  description = "Path to the packaged backend Lambda zip file"
  type        = string
  default     = "../artifacts/url-shortner-backend.zip"
}

# -----------------------------------------------------------------------------
# Frontend
# -----------------------------------------------------------------------------

# Globally unique name for the S3 bucket that hosts the Angular static files.
# Must follow S3 naming rules and be unique across all AWS accounts.
variable "frontend_bucket_name" {
  description = "Globally unique S3 bucket name for frontend static files"
  type        = string
}
