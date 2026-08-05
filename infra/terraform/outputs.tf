# =============================================================================
# outputs.tf
# =============================================================================
# Defines output values printed to the console after "terraform apply".
#
# These values are useful for:
#   - Referencing infrastructure details in CI/CD pipelines.
#   - Passing values to other Terraform modules via "terraform_remote_state".
#   - Quick operational lookups without navigating the AWS console.
# =============================================================================

# Full HTTPS URL of the API endpoint.
# Used by the frontend to configure the API base URL at build time.
output "api_custom_domain" {
  value       = "https://${var.api_subdomain}.${var.root_domain}"
  description = "API base URL"
}

# Full HTTPS URL of the Angular frontend.
output "frontend_custom_domain" {
  value       = "https://${var.frontend_subdomain}.${var.root_domain}"
  description = "Frontend URL"
}

# Name of the DynamoDB table currently in use.
# Useful for scripts that interact with the table directly (e.g., data migrations).
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.short_links.name
  description = "DynamoDB table in use"
}

# CloudFront distribution ID.
# Required when running cache invalidations after a frontend deployment:
#   aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.frontend.id
  description = "CloudFront distribution ID for cache invalidation"
}
