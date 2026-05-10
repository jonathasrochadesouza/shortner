# =============================================================================
# main.tf
# =============================================================================
# Main entry point for the URL Shortener infrastructure.
#
# Overall architecture:
#
#   Backend:
#     Internet -> API Gateway (HTTP API v2)
#                     -> Lambda (Java 21 / Spring Boot)
#                     -> DynamoDB
#     Custom domain: api.<root_domain> via Route53 + ACM
#
#   Frontend:
#     Internet -> CloudFront -> S3 (Angular SPA, private bucket)
#     Custom domain: shortner.<root_domain> via Route53 + ACM
#
# =============================================================================

# -----------------------------------------------------------------------------
# Terraform Configuration and Providers
# -----------------------------------------------------------------------------

terraform {
  # Minimum Terraform version required to ensure compatibility
  # with the resources and syntax used in this project.
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Allows patch/minor updates within v5.x
    }
  }
}

# Configures the AWS provider using the region defined in variables.tf.
provider "aws" {
  region = var.aws_region
}

# =============================================================================
# DATABASE — DynamoDB
# =============================================================================

# Table that stores the mappings from short codes to original URLs.
# - Primary key (hash_key): "short_link" (string) — the generated short code.
# - Billing mode PAY_PER_REQUEST: no provisioned capacity; charges per
#   read/write consumed. Ideal for variable or unpredictable traffic.
resource "aws_dynamodb_table" "short_links" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_link"

  attribute {
    name = "short_link"
    type = "S" # S = String (DynamoDB scalar type)
  }

  tags = local.tags
}

# =============================================================================
# IAM — Lambda Permissions
# =============================================================================

# IAM role that the Lambda function assumes at runtime.
# The trust policy (assume_role_policy) restricts assumption
# exclusively to the AWS Lambda service.
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

# IAM policy with the minimum permissions required for the Lambda to operate:
#   1. DynamoDB: GetItem (read) and PutItem (write) on the short links table.
#   2. CloudWatch Logs: create log groups/streams and push execution logs.
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem"]
        Resource = aws_dynamodb_table.short_links.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attaches the policy above to the Lambda role.
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# =============================================================================
# COMPUTE — Lambda Function
# =============================================================================

# Lambda function that runs the Spring Boot backend packaged as a ZIP artifact.
#
# Key settings:
#   - runtime: java21 — matches the Spring Boot version used in this project.
#   - handler: entry point for the AWS Lambda Runtime Interface (StreamLambdaHandler).
#   - timeout: 30s — accounts for JVM cold start overhead.
#   - memory_size: 1024 MB — balances cost and performance for Java workloads.
#   - source_code_hash: triggers re-deployment whenever the ZIP content changes.
#
# Environment variables injected into the Lambda at runtime:
#   - SHORTENER_TABLE_NAME: name of the DynamoDB table.
#   - SHORTENER_DOMAIN_BASE_URL: base URL used to build short links.
#   - SPRING_PROFILES_ACTIVE: activates the "aws" Spring profile.
resource "aws_lambda_function" "api" {
  function_name = "${var.project_name}-api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "com.jkrocha.shortner.lambda.StreamLambdaHandler::handleRequest"
  runtime       = "java21"
  timeout       = 30
  memory_size   = 1024
  filename      = var.lambda_zip_path

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      SHORTENER_TABLE_NAME      = var.dynamodb_table_name
      SHORTENER_DOMAIN_BASE_URL = "https://${var.api_subdomain}.${var.root_domain}"
      SPRING_PROFILES_ACTIVE    = "aws"
    }
  }

  tags = local.tags
}

# =============================================================================
# API GATEWAY — HTTP API v2
# =============================================================================

# Creates the HTTP API (v2) that acts as the entry point for all requests.
#
# CORS is configured to:
#   - Accept any request header.
#   - Allow methods: GET, POST, and OPTIONS (preflight).
#   - Allow origin: only the frontend domain (no wildcard in production).
resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_origins = ["https://${var.frontend_subdomain}.${var.root_domain}"]
  }

  tags = local.tags
}

# Integrates API Gateway with Lambda via AWS_PROXY.
# payload_format_version "2.0" is the latest recommended version for
# HTTP APIs, with cookie support and a simplified event payload.
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Route for creating short links.
# POST /api/v1/links -> Lambda
resource "aws_apigatewayv2_route" "create_link" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /api/v1/links"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Route for redirecting via the short code.
# GET /{shortCode} -> Lambda (which redirects to the original URL)
resource "aws_apigatewayv2_route" "redirect_link" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /{shortCode}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Default API Gateway stage.
# auto_deploy = true: any API change is published automatically
# without requiring manual deployment steps.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true

  tags = local.tags
}

# Explicit permission allowing API Gateway to invoke the Lambda function.
# source_arn scopes the permission to any route/method of this specific API.
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

# =============================================================================
# CUSTOM DOMAIN — API (api.<root_domain>)
# =============================================================================

# Registers the custom domain name in API Gateway.
# The ACM certificate must be REGIONAL (same region as the API Gateway).
# security_policy TLS_1_2 ensures secure communication with modern clients.
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "${var.api_subdomain}.${var.root_domain}"

  domain_name_configuration {
    certificate_arn = var.api_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.tags
}

# Maps the HTTP API to the custom domain name on the default stage.
resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.http.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.default.id
}

# Route53 DNS A record (alias) pointing to the API Gateway endpoint.
# Alias records avoid extra DNS query charges and support native health checks.
resource "aws_route53_record" "api_alias" {
  zone_id = var.route53_zone_id
  name    = "${var.api_subdomain}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# =============================================================================
# FRONTEND — S3 + CloudFront
# =============================================================================

# S3 bucket that hosts the Angular static build artifacts (production build).
# All public access is blocked — content is served exclusively through
# CloudFront using Origin Access Control (OAC).
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
  tags   = local.tags
}

# Blocks all public access to the S3 bucket.
# Ensures that files are never directly accessible over the internet
# and can only be served through CloudFront.
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control (OAC) — the modern, AWS-recommended mechanism
# to allow CloudFront to access private S3 buckets.
# Replaces the legacy Origin Access Identity (OAI) model.
# signing_behavior "always" + signing_protocol "sigv4" ensures that all
# CloudFront requests to S3 are signed with SigV4.
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project_name}-frontend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution for the Angular frontend (SPA).
#
# Key settings:
#   - default_root_object: serves index.html at the domain root.
#   - aliases: custom domain name for the frontend.
#
# Cache behaviors:
#   - default: static assets (JS, CSS, images) with standard CloudFront caching,
#              HTTP -> HTTPS redirect enforced.
#   - *.html: TTL zero (min/default/max = 0) so the browser and CloudFront
#             always fetch the latest version — critical for SPA deployments.
#
# Custom error responses:
#   - 403 and 404 are mapped to /index.html with HTTP 200 — required so the
#     Angular Router can handle client-side routes correctly.
#     (S3 returns 403/404 for paths that do not exist as objects.)
#
# TLS certificate:
#   - ACM certificate in us-east-1 (required by CloudFront).
#   - ssl_support_method "sni-only" is the modern default with no extra cost.
#   - Minimum protocol TLSv1.2_2021 for current security standards.
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["${var.frontend_subdomain}.${var.root_domain}"]

  # Origin: private S3 bucket accessed via OAC
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "frontend-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # Default cache behavior for all static assets (JS, CSS, images, etc.)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "frontend-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Specific cache behavior for HTML files.
  # Zero TTL ensures the browser always fetches the latest version of
  # index.html after each deployment, preventing stale cache issues.
  ordered_cache_behavior {
    path_pattern     = "*.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "frontend-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # Redirects S3 403 errors to /index.html (Angular Router client-side routing)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  # Redirects S3 404 errors to /index.html (Angular Router client-side routing)
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  # No geographic restrictions — content is available globally
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ACM certificate for HTTPS on the custom domain.
  # Must be in us-east-1 (CloudFront requirement).
  viewer_certificate {
    acm_certificate_arn      = var.frontend_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

# S3 bucket policy that authorizes only CloudFront (via OAC) to read objects.
# The AWS:SourceArn condition scopes access to this specific distribution,
# preventing other CloudFront distributions from accessing the bucket.
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
}

# Route53 DNS A record (alias) pointing to the CloudFront distribution.
resource "aws_route53_record" "frontend_alias" {
  zone_id = var.route53_zone_id
  name    = "${var.frontend_subdomain}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}
