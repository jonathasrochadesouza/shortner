<p align="center">
  <img src="https://github.com/user-attachments/assets/b8fc7644-e56b-4fb4-a8c0-df76af52d2ea" alt="URL Shortener Logo" width="550" />
</p>

> A **cloud-native**, **serverless** URL Shortener built with modern Java and AWS infrastructure — fast, scalable, and production-ready.

![Java](https://img.shields.io/badge/Java-21_LTS-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![AWS Lambda](https://img.shields.io/badge/AWS_Lambda-Serverless-FF9900?style=for-the-badge&logo=awslambda&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![DynamoDB](https://img.shields.io/badge/DynamoDB-NoSQL-4053D6?style=for-the-badge&logo=amazondynamodb&logoColor=white)
![API Gateway](https://img.shields.io/badge/API_Gateway-REST-FF4F8B?style=for-the-badge&logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📖 Overview

**URL Shortener** is a fully serverless application that converts long URLs into short, shareable links. Built on top of AWS managed services and provisioned entirely with Terraform, it is designed to be **cost-efficient**, **highly available**, and **easy to deploy**.

This project follows clean architecture principles and leverages the full power of **Java 21 LTS** virtual threads and modern APIs.

---

## ✨ Features

- 🔗 **Shorten URLs** — Generate compact, unique short links
- 🔁 **Redirect** — Seamless HTTP 301/302 redirection from short → original URL
- 📊 **Analytics (optional)** — Track access count per short URL
- ⏳ **TTL Support** — Set expiration time for links
- 🔐 **Authentication (optional)** — API Key or JWT-based access control via API Gateway
- 🌍 **Custom Domain** — Support for custom domains via Route 53 + ACM
- ⚡ **Serverless** — Zero server management, scales automatically
- 🏗️ **Infrastructure as Code** — 100% provisioned via Terraform

---

## 🏛️ Architecture

```
┌─────────────┐       ┌─────────────────────┐       ┌───────────────────┐
│   Client    │──────▶│  AWS API Gateway     │──────▶│  AWS Lambda       │
│  (Browser)  │       │  (REST / HTTP API)   │       │  (Java 21 LTS)    │
└─────────────┘       └─────────────────────┘       └────────┬──────────┘
                                                             │
                                                   ┌─────────▼──────────┐
                                                   │  AWS DynamoDB       │
                                                   │  (URL Store + TTL)  │
                                                   └────────────────────┘
```

### 🔧 Tech Stack

| Layer             | Technology                      |
|-------------------|---------------------------------|
| Language          | Java 21 LTS (Virtual Threads)   |
| Runtime           | AWS Lambda (SnapStart enabled)  |
| API               | AWS API Gateway (HTTP API)      |
| Database          | AWS DynamoDB (On-Demand)        |
| Infrastructure    | Terraform                       |
| Build Tool        | Maven / Gradle                  |
| Logging           | AWS CloudWatch Logs             |
| Monitoring        | AWS CloudWatch Metrics + Alarms |
| CI/CD (optional)  | GitHub Actions                  |

---

## 📁 Project Structure

```
url-shortner/
├── 📂 src/
│   ├── 📂 main/java/com/urlshortner/
│   │   ├── 📂 handler/          # Lambda handlers (create, redirect)
│   │   ├── 📂 service/          # Business logic
│   │   ├── 📂 repository/       # DynamoDB repository layer
│   │   ├── 📂 model/            # Domain models & DTOs
│   │   └── 📂 util/             # Utilities (ID generator, validators)
│   └── 📂 test/                 # Unit & integration tests
├── 📂 infra/                    # Terraform infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── lambda.tf
│   ├── apigateway.tf
│   ├── dynamodb.tf
│   └── iam.tf
├── 📂 .github/
│   └── 📂 workflows/            # GitHub Actions CI/CD pipelines
├── 📄 pom.xml
├── 📄 README.md
└── 📄 .gitignore
```

---

## 🚀 Getting Started

### Prerequisites

- ☕ **Java 21 LTS** (`JAVA_HOME` configured)
- 🐘 **Maven 3.9+** or **Gradle 8+**
- 🏗️ **Terraform 1.6+**
- ☁️ **AWS CLI** configured with valid credentials
- 🔑 **AWS Account** with appropriate permissions

### 1️⃣ Clone the repository

```bash
git clone https://github.com/jonathasrochadesouza/url-shortner.git
cd url-shortner
```

### 2️⃣ Build the Lambda package

```bash
mvn clean package -DskipTests
```

### 3️⃣ Deploy infrastructure with Terraform

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 4️⃣ Test the API

**Shorten a URL:**
```bash
curl -X POST https://<api-id>.execute-api.us-east-1.amazonaws.com/short \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.example.com/very/long/url/that/needs/shortening"}'
```

**Response:**
```json
{
  "shortUrl": "https://short.ly/aB3xZ9",
  "originalUrl": "https://www.example.com/very/long/url/that/needs/shortening",
  "expiresAt": "2026-06-07T00:00:00Z"
}
```

**Redirect:**
```bash
curl -L https://<api-id>.execute-api.us-east-1.amazonaws.com/aB3xZ9
```

---

## ⚙️ Environment Variables

| Variable              | Description                        | Default        |
|-----------------------|------------------------------------|----------------|
| `DYNAMODB_TABLE_NAME` | DynamoDB table name                | `url-shortner` |
| `BASE_URL`            | Base URL for generated short links | *(required)*   |
| `DEFAULT_TTL_DAYS`    | Default expiration in days         | `30`           |
| `AWS_REGION`          | AWS deployment region              | `us-east-1`    |

---

## 🗺️ Roadmap

- [x] Project setup & architecture definition
- [ ] Core Lambda handlers (create + redirect)
- [ ] DynamoDB repository implementation
- [ ] Terraform infrastructure (Lambda, API GW, DynamoDB)
- [ ] Custom domain + Route 53 integration
- [ ] Click analytics & reporting
- [ ] GitHub Actions CI/CD pipeline
- [ ] QR Code generation endpoint

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch: `git checkout -b feat/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push to the branch: `git push origin feat/my-feature`
5. Open a Pull Request

---

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/jonathasrochadesouza">Jonathas Rocha</a>
</p>
















##  URL Shortner (Java 21 + AWS Serverless + Angular)

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

