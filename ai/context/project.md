# Project Context

`shortner` is a full-stack URL shortener MVP.

## Implemented Stack

- Frontend: Angular in `frontend/`
- Backend: Java 21 Spring Boot in `backend/`
- Storage: DynamoDB table named `url-shortner`
- Local services: Docker Compose with DynamoDB Local
- Infrastructure draft: Terraform in `infra/terraform/`
- API contract: OpenAPI in `openapi/openapi.yaml`

## Current Behavior

- `POST /api/v1/links` creates a short link for an `http://` or `https://` URL.
- Short codes are random 8-character base62 strings.
- DynamoDB stores `short_link` and `original_link`.
- `GET /{shortCode}` resolves a short code and returns an HTTP redirect.
- `GET /api/v1/links` lists saved links.

## Not Yet Implemented

- TTL expiration
- Analytics
- Authentication or authorization
- CI/CD
- Complete Lambda artifact packaging
- Fully aligned production Terraform routes and permissions

Treat the code as the source of truth when documentation disagrees.
