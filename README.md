# 🔗 URL Shortener

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
