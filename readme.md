# YouTube Video Links Extractor

This project deploys a serverless web application on AWS that allows users to extract all video links from a given YouTube channel. The application is built using a combination of AWS services including Lambda, API Gateway, and S3, all provisioned and managed by Terraform.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup and Deployment](#setup-and-deployment)
- [How to Use](#how-to-use)
- [File Structure](#file-structure)
- [Developer's Report](#developers-report)
- [Step-by-Step Developer's Guide to Building From Scratch](#step-by-step-developers-guide-to-building-from-scratch)

---

## Project Overview
The primary goal of this project is to provide a simple and efficient way to get a list of all video URLs from a YouTube channel. A user provides a YouTube channel ID, and the application returns a list of all video links from that channel's "uploads" playlist. The frontend is a simple HTML page hosted on S3, and the backend logic is handled by a Python Lambda function.

---

## Architecture
The application follows a serverless architecture, which is cost-effective and scalable.

* **Frontend (Amazon S3):** A static HTML webpage is hosted on an S3 bucket configured for static website hosting. This page provides the user interface for entering the YouTube channel ID.
* **API (Amazon API Gateway):** An API Gateway endpoint is set up to receive requests from the frontend. It is configured with a POST method that triggers the Lambda function. CORS is enabled to allow cross-origin requests from the S3 website.
* **Backend Logic (AWS Lambda):** A Python-based Lambda function contains the core logic. It receives the channel ID from the API Gateway, uses the YouTube Data API v3 to fetch the channel's uploads playlist, and then retrieves all video links from that playlist. The YouTube API key is securely stored as an environment variable in the Lambda function.
* **Permissions (AWS IAM):** An IAM role is created for the Lambda function, granting it the necessary permissions to execute and write logs to CloudWatch (`AWSLambdaBasicExecutionRole`).

---

## Features
- **Serverless:** No servers to manage. The application scales automatically with demand.
- **Simple Web Interface:** An easy-to-use interface to input the channel ID.
- **Bulk Link Extraction:** Fetches all video links from a channel, handling pagination automatically.
- **Downloadable List:** Provides the extracted links in a textarea for easy copying and offers a "Download .txt" feature.
- **Infrastructure as Code:** The entire AWS infrastructure is defined and managed using Terraform, making it easy to replicate and manage.

---

## Prerequisites
Before you begin, ensure you have the following installed and configured:

- **Terraform:** Version 1.0.0 or higher.
- **AWS CLI:** Configured with your AWS credentials and a default region.
- **A YouTube Data API v3 Key:** You can obtain one from the Google Cloud Console.

---

## Setup and Deployment
1.  **Clone the repository:**
    ```sh
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Update Configuration:**
    Navigate to `envs/dev/terraform.tfvars` and update the `youtube_api_key` with your own key from the Google Cloud Console. You can also change other variables like `aws_region` or `bucket_name` if needed.
    ```hcl
    # envs/dev/terraform.tfvars
    lambda_function_name = "youtubeLinkExtractor"
    # ...
    youtube_api_key      = "YOUR_YOUTUBE_API_KEY"
    # ...
    aws_region           = "ap-south-1"
    ```

3.  **Package the Lambda function:**
    The Terraform configuration for the Lambda module expects a `lambda_function_payload.zip` file containing the Python code. Navigate to the `modules/lambda` directory and create the zip file:
    ```sh
    cd modules/lambda
    zip lambda_function_payload.zip lambda_function.py
    cd ../..
    ```
    *Note: If you have dependencies, you would install them in a package directory and zip the contents.*

4.  **Deploy with Terraform:**
    Navigate to the `envs/dev` directory and run the following Terraform commands:
    ```sh
    cd envs/dev
    terraform init
    terraform plan
    terraform apply
    ```
    When prompted, type `yes` to confirm the deployment. Terraform will provision all the necessary AWS resources.

5.  **Access the Application:**
    Once the deployment is complete, Terraform will output the URL of the S3 static website (`s3_website_url`). Open this URL in your web browser to use the application.

---

## How to Use
1.  Open the S3 website URL in your browser.
2.  Find the YouTube channel ID you want to extract links from. It's usually in the channel's URL (e.g., `UC...`).
3.  Enter the **Channel ID** into the input field on the webpage.
4.  Click the **"Extract Video Links"** button.
5.  The application will display the total number of links found and list them in the text area.
6.  You can copy the links directly or click the **"Download .txt"** button to save them to a file.

---

## File Structure
```
├── .gitignore
├── envs
│   └── dev
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── modules
│   ├── api_gateway
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── lambda
│   │   ├── lambda_function.py
│   │   ├── lambda_function_payload.zip
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── s3
│       ├── index.html.tftpl
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── versions.tf
├── requirements.txt
└── youtube_video_links.py
```


-   **`envs/dev`**: Contains the root Terraform configuration for the development environment. It calls the modules to create the infrastructure.
-   **`modules`**: Contains reusable Terraform modules for each part of the infrastructure (API Gateway, IAM, Lambda, S3).
    -   **`api_gateway`**: Defines the API Gateway REST API, resources, methods, and integration with the Lambda function.
    -   **`iam`**: Creates the IAM role and policy attachments for the Lambda function.
    -   **`lambda`**: Creates the Lambda function and packages the Python code. `lambda_function.py` is the actual serverless function code.
    -   **`s3`**: Creates the S3 bucket for the static website and uploads the `index.html` file.
-   **`youtube_video_links.py`**: A local Python script for testing the YouTube API logic independently.
-   **`requirements.txt`**: Lists the Python dependencies for the local test script.

---

## Developer's Report
This section provides a more in-depth technical overview for developers looking to understand or extend the project.

### Terraform Structure
The project uses a standard Terraform module structure. The `envs/dev` directory acts as the root module for the development environment. This separation allows for creating other environments (e.g., `staging`, `prod`) easily by duplicating the `dev` directory and changing the variables in `terraform.tfvars`.

-   **`envs/dev/main.tf`**: This is the entry point. It orchestrates the deployment by calling the other modules and passing necessary variables between them. For example, the `lambda_role_arn` from the `iam` module is passed to the `lambda` module.
-   **Modules (`modules/*`)**: Each module is self-contained and responsible for a specific piece of the infrastructure. This promotes reusability and maintainability.
-   The **S3 module** uses a `.tftpl` file for the `index.html`. This allows Terraform to inject the API Gateway URL directly into the HTML file during deployment, so the frontend knows where to send its requests.
-   The **Lambda module** packages the `lambda_function.py` into a `.zip` archive, which is required for deployment. Any change to the Python code requires re-zipping and re-running `terraform apply`.

### Backend (Lambda Function)
The `modules/lambda/lambda_function.py` script is the heart of the application's logic.

-   It's written in Python and uses the `urllib3` library to make HTTP requests to the YouTube API. This avoids the need to package the larger `google-api-python-client` library, keeping the deployment package small.
-   The YouTube API key is accessed via an environment variable (`YOUTUBE_API_KEY`), which is a security best practice.
-   The function first finds the `uploads` playlist ID for the given channel ID.
-   It then paginates through the playlist items to fetch all video IDs and constructs the full YouTube video URLs.
-   Error handling is included for cases like an invalid channel ID or API errors.
-   The function returns a JSON response formatted for API Gateway, including CORS headers (`Access-Control-Allow-Origin: *`) to allow the S3 frontend to access it.

### Frontend (S3 Website)
The `modules/s3/index.html.tftpl` file is a simple but effective user interface.

-   It uses Tailwind CSS for styling, loaded via a CDN.
-   The core logic is in the `<script>` tag.
-   The `API_GATEWAY_URL` constant is a placeholder (`${api_gateway_url}`) that Terraform replaces with the actual API Gateway invoke URL during deployment.
-   When the "Extract Video Links" button is clicked, it makes an asynchronous `fetch` request (POST) to the API Gateway endpoint.
-   The request body contains the `channelId` from the input field.
-   It handles the response from the Lambda function, displaying the video links or an error message as needed.

### Local Development and Testing
The `youtube_video_links.py` file in the root directory is a standalone script that can be used for local testing of the YouTube API interaction logic.

-   It uses the `google-api-python-client` library, so you'll need to install the dependencies from `requirements.txt` (`pip install -r requirements.txt`).
-   It prompts for a channel ID and writes the output to a local `youtube_video_links.txt` file. This is useful for debugging the YouTube API part of the code without needing to deploy to AWS.
-   *Note: The API key is hardcoded in this test script. For production use, it's better to use environment variables as is done in the Lambda function.*

---

## Step-by-Step Developer's Guide to Building From Scratch
This guide walks through how to construct this project from the ground up. It explains how each module is built and connected.

### Step 1: Foundational Setup
Before writing any Terraform code, ensure you have your tools ready:

1.  **Install Terraform and the AWS CLI.**
2.  **Configure AWS Credentials:** Run `aws configure` and provide your AWS Access Key ID and Secret Access Key.
3.  **Get a YouTube API Key:** Create a project in the Google Cloud Console, enable the "YouTube Data API v3", and generate an API key.

### Step 2: Creating the Lambda Execution Role (IAM Module)
Every Lambda function needs an IAM role to grant it permissions.

1.  Create the `modules/iam` directory.
2.  In `modules/iam/main.tf`, define an IAM role that the Lambda service can assume. Attach the AWS-managed `AWSLambdaBasicExecutionRole` policy to allow the function to write logs to CloudWatch.
    ```hcl
    # modules/iam/main.tf
    resource "aws_iam_role" "lambda_exec" {
      name = "lambda_exec_role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = { Service = "lambda.amazonaws.com" }
        }]
      })
    }

    resource "aws_iam_role_policy_attachment" "lambda_basic" {
      role       = aws_iam_role.lambda_exec.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    }
    ```
3.  In `modules/iam/outputs.tf`, output the ARN of the created role so other modules can use it.

### Step 3: Writing and Packaging the Lambda Function (Lambda Module)
This module handles the application's core logic.

1.  Create the `modules/lambda` directory.
2.  Write the Python logic in `modules/lambda/lambda_function.py`. This script will parse the `channelId` from the request, call the YouTube API, and return the list of video links.
3.  Package the function: Run `zip lambda_function_payload.zip lambda_function.py` inside the `modules/lambda` directory.
4.  In `modules/lambda/main.tf`, define the `aws_lambda_function` resource. This configuration points to the zip file, sets the handler and runtime, and importantly, assigns the role from the IAM module's output and sets the `YOUTUBE_API_KEY` environment variable.

### Step 4: Creating the Frontend Interface (S3 Module)
This module creates the S3 bucket to host the static HTML frontend.

1.  Create the `modules/s3` directory.
2.  Create an HTML template file, `modules/s3/index.html.tftpl`. This file contains the HTML, CSS (via Tailwind CDN), and JavaScript for the user interface. Use a placeholder `${api_gateway_url}` where the API endpoint will be injected.
3.  In `modules/s3/main.tf`, define resources to:
    -   Create an `aws_s3_bucket`.
    -   Configure it for static website hosting using `aws_s3_bucket_website_configuration`.
    -   Make the bucket contents public with `aws_s3_bucket_policy` and `aws_s3_bucket_public_access_block`.
    -   Use a `template_file` data source to render the `index.html.tftpl` with the API Gateway URL.
    -   Upload the rendered HTML to the bucket using `aws_s3_object`.

### Step 5: Exposing the Lambda via API Gateway (API Gateway Module)
This module creates a public HTTP endpoint for the Lambda function.

1.  Create the `modules/api_gateway` directory.
2.  In `modules/api_gateway/main.tf`, define the following resources:
    -   `aws_api_gateway_rest_api`: The main container for your API.
    -   `aws_api_gateway_resource`: A path for the API (e.g., `/links`).
    -   `aws_api_gateway_method`: The HTTP method (POST) for your resource.
    -   `aws_api_gateway_integration`: Connects the POST method to your Lambda function (`AWS_PROXY` integration).
    -   **CORS Configuration:** Define an `OPTIONS` method with a `MOCK` integration and appropriate headers (`Access-Control-Allow-Origin`, etc.). This is crucial for allowing the browser to make cross-origin requests from the S3 website to the API.
    -   `aws_lambda_permission`: Grants API Gateway permission to invoke your Lambda function.
    -   `aws_api_gateway_deployment` and `aws_api_gateway_stage`: To deploy the API and make it accessible.
3.  In `modules/api_gateway/outputs.tf`, output the `invoke_url` of the deployed stage.

### Step 6: Assembling the Infrastructure (Root Module)
The `envs/dev` directory ties everything together.

1.  In `envs/dev/main.tf`, declare `module` blocks for each of the modules created above (`iam`, `lambda`, `s3`, `api_gateway`).
2.  Connect the modules using their inputs and outputs:
    -   Pass the output `lambda_role_arn` from the `iam` module to the `lambda_role_arn` variable of the `lambda` module.
    -   Pass the output `lambda_function_arn` from the `lambda` module to the `lambda_invoke_arn` variable of the `api_gateway` module.
    -   Pass the output `api_invoke_url` from the `api_gateway` module to the `api_gateway_url` variable of the `s3` module.
3.  Define your input variables (like `youtube_api_key`) in `envs/dev/variables.tf` and set their values in `envs/dev/terraform.tfvars`.

### Step 7: Final Deployment
With all the pieces in place, navigate to the `envs/dev` directory and run the standard Terraform workflow:
```sh
terraform init
terraform plan
terraform apply
```
Terraform will read your configuration, build a dependency graph (e.g., it knows to create the IAM role before the Lambda function), and provision all the resources in the correct order.