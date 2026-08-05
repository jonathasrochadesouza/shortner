# =============================================================================
# locals.tf
# =============================================================================
# Defines local values shared across all resources in this module.
#
# Locals are computed once and referenced by name, avoiding repetition
# and making global changes (e.g., adding a new tag) easier to manage.
# =============================================================================

locals {
  # Standard tags applied to every AWS resource.
  # - Project: identifies the owning project for cost allocation.
  # - Environment: distinguishes prod, staging, etc.
  # - ManagedBy: signals that this resource is managed by Terraform
  #              and should not be modified manually.
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
