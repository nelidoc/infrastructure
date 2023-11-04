# Infrastructure
This repository is the centralized hub for Neli's infrastructure-as-code, managing cloud resources and configurations with efficiency and reliability.

## Repository

The source code for the website is hosted on GitHub and can be accessed here:

- [https://github.com/nelidoc/website](https://github.com/nelidoc/website)

The Docker image for the website is constructed from this source and is subsequently pushed to Docker Hub, from where it is deployed to Google Cloud Run.

## Replication

Replication is limited to a single replica to ensure cost-effectiveness and compliance with the initial deployment specifications.

The service is configured not to scale beyond one instance to maintain a single source of truth.

## Secret Management

Sensitive information and configuration details required by the website are managed securely using Google Cloud Secrets Manager. This ensures that secrets are not exposed in the codebase and are handled according to security best practices.

## DNS Configuration

DNS records are dynamically created and updated to ensure `nelidoc.com` always resolves to the current deployment on Google Cloud Run.

- **Automation**: Terraform configurations are used to manage DNS records.
- **Consistency**: Changes in deployment reflect immediately in DNS configurations.

## Terraform State Management

The state of our Terraform deployment is securely stored in a Google Cloud Storage bucket called `nelidoc-tfstates`. This approach guarantees a safe, version-controlled state file that is crucial for team collaboration and infrastructure tracking.

- **Bucket Name**: `nelidoc-tfstates`
- **Features**: Encrypted storage, versioning, and rollback capabilities.

Please ensure that your Google Cloud project and credentials are correctly set up before attempting to deploy the infrastructure with Terraform.
