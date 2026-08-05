# Repository Rules

## Naming

Use the project spelling `shortner`.

Do not silently rename packages, domains, artifact names, table names, or
project identifiers from `shortner` to `shortener`.

Important names:

- Java package: `com.jkrocha.shortner`
- Backend artifact: `url-shortner-backend`
- DynamoDB table: `url-shortner`
- Local backend URL: `http://localhost:8080`
- Local frontend URL: `http://localhost:4200`

## Change Discipline

- Read relevant files before editing.
- Keep changes scoped to the request.
- Preserve user changes already present in the worktree.
- Avoid unrelated formatting churn.
- Keep backend, frontend, OpenAPI, and Terraform aligned when API behavior changes.
- Do not add DynamoDB indexes, TTL fields, analytics counters, or schema changes unless explicitly requested.

## Verification

Choose the smallest useful verification:

- Backend logic: `cd backend && mvn test`
- Backend package: `cd backend && mvn clean package`
- Frontend build: `cd frontend && npm run build`
- Frontend tests: `cd frontend && npm test`
- Terraform formatting: `cd infra/terraform && terraform fmt`
- Terraform validation: `cd infra/terraform && terraform validate`
- Full local stack: `docker compose up --build`

Do not run `terraform apply` unless explicitly requested.
