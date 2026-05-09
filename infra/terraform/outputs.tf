output "api_custom_domain" {
  value       = "https://${var.api_subdomain}.${var.root_domain}"
  description = "API base URL"
}

output "frontend_custom_domain" {
  value       = "https://${var.frontend_subdomain}.${var.root_domain}"
  description = "Frontend URL"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.short_links.name
  description = "DynamoDB table in use"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.frontend.id
  description = "CloudFront distribution ID for cache invalidation"
}
