# URL Shortner (Java 21 + AWS Serverless + Angular)

Production-ready URL shortener platform with:

- **Backend**: Java 21 (Spring Boot, AWS Lambda adapter)
- **Frontend**: Angular latest + Angular Material
- **Storage**: DynamoDB (`short_link`, `original_link`)
- **Infra as Code**: Terraform
- **Cloud**: AWS Lambda + API Gateway + Route53 + S3 + CloudFront
- **Contract**: OpenAPI 3.1 (`/openapi/openapi.yaml`)
- **License**: MIT

---

## 1) Architecture

- `POST /api/v1/links` creates a short link and stores the mapping in DynamoDB.
- `GET /{shortCode}` resolves DynamoDB by `short_link` and returns HTTP 302 redirect to `original_link`.
- Backend is designed to run locally as Spring Boot and in AWS as Lambda.
- Frontend is a serverless static app hosted in S3 + CloudFront on subdomain `shortner.<domain>`.

---

## 2) Repository layout

- `/backend` → Java 21 backend and Lambda handler
- `/frontend` → Angular UI
- `/infra/terraform` → AWS infrastructure definitions
- `/openapi/openapi.yaml` → API specification
- `/docker-compose.yml` → local multi-service environment

---

## 3) Prerequisites

- Java 21
- Maven 3.9+
- Node.js 22+
- Docker + Docker Compose
- Terraform 1.7+
- AWS CLI configured

---

## 4) Unit tests (step-by-step)

### Backend (JUnit 5 + Mockito)

```bash
cd /home/runner/work/url-shortner/url-shortner/backend
mvn clean test
```

### Frontend unit tests

```bash
cd /home/runner/work/url-shortner/url-shortner/frontend
npm ci
npm test -- --watch=false
```

---

## 5) Run locally with Docker (step-by-step)

From project root:

```bash
cd /home/runner/work/url-shortner/url-shortner
docker compose up --build
```

Local endpoints:

- Backend API: `http://localhost:8080`
- Frontend UI: `http://localhost:4200`
- DynamoDB Local: `http://localhost:8000`

### Local usage flow

1. Open frontend on `http://localhost:4200`
2. Submit an original URL
3. API stores in DynamoDB Local
4. Use generated short link to trigger backend redirect

---

## 6) Build artifacts for release

### Backend Lambda package

```bash
cd /home/runner/work/url-shortner/url-shortner/backend
mvn clean package -DskipTests
mkdir -p /home/runner/work/url-shortner/url-shortner/infra/artifacts
cp target/url-shortner-backend-1.0.0.jar /home/runner/work/url-shortner/url-shortner/infra/artifacts/
cd /home/runner/work/url-shortner/url-shortner/infra/artifacts
zip url-shortner-backend.zip url-shortner-backend-1.0.0.jar
```

### Frontend static package

```bash
cd /home/runner/work/url-shortner/url-shortner/frontend
npm ci
npm run build
```

---

## 7) Terraform deployment (step-by-step)

```bash
cd /home/runner/work/url-shortner/url-shortner/infra/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

After apply, upload frontend build:

```bash
aws s3 sync /home/runner/work/url-shortner/url-shortner/frontend/dist/frontend/browser s3://<frontend_bucket_name> --delete
aws cloudfront create-invalidation --distribution-id <cloudfront_distribution_id> --paths "/*"
```

---

## 8) Terraform fields you must change

In `infra/terraform/terraform.tfvars`:

- `route53_zone_id` → your Route53 hosted zone ID for `jkrocha.com.br`
- `api_certificate_arn` → ACM cert ARN for `api.jkrocha.com.br` (regional)
- `frontend_certificate_arn` → ACM cert ARN in `us-east-1` for `shortner.jkrocha.com.br`
- `frontend_bucket_name` → globally unique bucket name
- `lambda_zip_path` → actual packaged backend zip path

Optional but commonly adjusted:

- `aws_region`
- `project_name`
- `environment`
- `root_domain`, `api_subdomain`, `frontend_subdomain`

---

## 9) Docker details

- `backend/Dockerfile` builds and runs Java 21 backend.
- `frontend/Dockerfile` builds Angular and serves with Nginx.
- `docker-compose.yml` starts backend, frontend, DynamoDB Local, and table initialization.

---

## 10) API contract

OpenAPI spec is available at:

- `/home/runner/work/url-shortner/url-shortner/openapi/openapi.yaml`

---

## 11) DNS targets

- API custom domain: `api.jkrocha.com.br`
- Frontend custom domain: `shortner.jkrocha.com.br`

Both are provisioned by Terraform using Route53 records.

---

## 12) Security and operational notes

- Restrict CORS origins in production (`infra/terraform/main.tf` API CORS section).
- Store secrets in AWS Systems Manager Parameter Store or Secrets Manager.
- Enable CloudWatch alarms for Lambda errors and API 5xx rates.

