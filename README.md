# Infrastructure POC - AWS ECS Deployment

A complete infrastructure-as-code setup for deploying a simple web application to AWS ECS (Elastic Container Service) using Terraform and GitHub Actions for automated CI/CD.

## 🏗️ Architecture

This project provisions:
- **VPC** with public subnets across multiple availability zones
- **ECS Fargate** cluster for containerized application deployment
- **ECR** repository for Docker image storage
- **Application Load Balancer** (optional, can be added)
- **Security Groups** for network access control
- **CloudWatch** logging for monitoring

## 📁 Project Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # Core AWS resources (VPC, ECS, ECR, etc.)
│   ├── variables.tf       # Configuration variables
│   ├── outputs.tf         # Terraform outputs
│   └── provider.tf        # AWS provider configuration
├── src/                   # Application source code
│   └── index.html         # Simple "Hello World" web page
├── Dockerfile             # Container build instructions
├── .github/workflows/     # CI/CD pipeline
│   └── deploy.yml         # GitHub Actions deployment workflow
└── README.md              # This file
```

## 🚀 Deployment

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform (>= 1.0)
- GitHub repository with Actions enabled
- AWS credentials stored as GitHub Secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

### Step 1: Deploy Infrastructure

First, create the AWS infrastructure using Terraform:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will create:
- VPC with public subnets
- ECS cluster and service
- ECR repository
- Required IAM roles and security groups

### Step 2: Configure GitHub Secrets

In your GitHub repository:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Step 3: Deploy Application

Push your code to the main branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy application to ECS"
git push origin main
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automates:

1. **Checkout**: Gets the latest code
2. **AWS Authentication**: Configures AWS credentials
3. **ECR Login**: Authenticates with Amazon ECR
4. **Build & Push**: Creates Docker image and pushes to ECR
5. **ECS Deployment**: Updates the ECS service with the new image

### Workflow Triggers

- **Push to main branch**: Automatic deployment
- **Manual trigger**: Can be run manually from GitHub Actions tab

### Environment Variables

- `AWS_REGION`: us-east-1 (configurable in workflow and Terraform)
- `ECR_REPOSITORY`: hello-world-app
- `IMAGE_TAG`: latest

## 🌐 Accessing Your Application

After successful deployment:

1. Go to **AWS ECS Console**
2. Navigate to your cluster (`hello-world-cluster`)
3. Click on **Tasks** → **Running Task**
4. Find the **Public IP** under **Configuration**
5. Open the IP address in your browser

You should see: **"Hello World from ECS!"**

## 🛠️ Customization

### Changing the Application

- Edit `src/index.html` for content changes
- Modify `Dockerfile` for different base images
- Update Terraform variables in `terraform/variables.tf`

### Scaling

- Adjust `desired_count` in `terraform/main.tf` for more instances
- Modify CPU/memory in the ECS task definition

### Networking

- Add ALB for load balancing and custom domains
- Configure private subnets for enhanced security
- Add Route 53 for DNS management

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

⚠️ **Warning**: This will permanently delete all AWS resources created by this project.
