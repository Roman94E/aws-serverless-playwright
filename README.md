# aws-serverless-playwright
Serverless browser automation and web scraping with Playwright on AWS Lambda using a modular, container-based architecture. 
Run dynamic Python scripts from S3 without redeploying.


This project provides a flexible, containerized architecture for running Playwright-powered **web scraping** and **browser automation** tasks on AWS Lambda. Inspired by [this article on Medium](https://medium.com/@luizfelipeverosa/serverless-web-scraping-with-playwright-and-aws-lambda-450b7a3fa42e), this implementation enhances the concept with dynamic script loading, modular design, and secure deployment practices.

## 🚀 Key Features

- 🧩 **Dynamic Script Execution**: Load and run Python scripts from S3 at runtime — no redeploy required.
- 🐳 **Container-based Deployment**: Uses a custom AWS Lambda Docker image for full control.
- 🧼 **Scraping & Automation Ready**: Use Playwright for data extraction, user flow simulation, or headless testing.
- 🔐 **Secure by Design**: Decoupled logic with tight S3 access controls.

---

## 📁 Project Structure

```
.
├── Dockerfile              # Lambda-compatible container
├── lambda_loader.py        # Bootstrap handler that runs external scripts from S3
├── requirements.txt        # Python dependencies
└── scraping-scripts/
    └── sample_scraper.py   # Example script to upload to S3
```

---

## 🧪 Example Lambda Event

```json
{
  "external_code_location": {
    "s3_code_bucket": "my-scraping-code-bucket",
    "s3_code_key": "scripts/sample_scraper.py"
  }
}
```

Your S3-hosted script must contain a `handler(event, context)` function.

---

## 🐋 Building & Deploying

### 1. Build Docker Image

```bash
docker build -t serverless-playwright .
```

### 2. Push to ECR

```bash
aws ecr create-repository --repository-name serverless-playwright

docker tag serverless-playwright:latest <your-account-id>.dkr.ecr.<region>.amazonaws.com/serverless-playwright

docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/serverless-playwright
```

### 3. Create Lambda Function

```bash
aws lambda create-function   --function-name serverless-playwright   --package-type Image   --code ImageUri=<your-ecr-image-uri>   --role <your-lambda-execution-role>
```

---

## ✍️ Writing External Scripts (Scraping / Automation)

Your Python scripts (stored in S3) should define a `handler` function.

### Example: Web Scraping

```python
def handler(event, context):
    from playwright.sync_api import sync_playwright
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto("https://example.com")
        data = page.title()
        browser.close()
        return {"title": data}
```

### Example: UI Automation

```python
def handler(event, context):
    from playwright.sync_api import sync_playwright
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto("https://example.com/login")
        page.fill("input#username", "user")
        page.fill("input#password", "pass")
        page.click("button#login")
        browser.close()
        return {"status": "Logged in"}
```

Upload these scripts to S3 and trigger the Lambda using the appropriate event.

---

## 🛡️ Security Tips

- Use IAM policies to restrict S3 access to trusted accounts/services
- Sanitize or validate dynamic script sources
- Avoid exposing Lambda to public invocation unless strictly necessary

---

## 📄 License

MIT License

---

## 🙏 Credits

Based on work by [Luiz Felipe Verosa](https://medium.com/@luizfelipeverosa/serverless-web-scraping-with-playwright-and-aws-lambda-450b7a3fa42e), with enhancements for runtime flexibility and modular scripting.
