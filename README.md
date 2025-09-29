# Terraform AWS Project – VPC, EC2, S3 & Load Balancer

This project provisions a complete AWS infrastructure using **Terraform**, including a VPC, subnets, internet gateway, route tables, security groups, EC2 instances, an S3 bucket, and an Application Load Balancer (ALB).  

## 🚀 Project Overview

The Terraform configuration will deploy the following resources:

- **VPC** with CIDR range defined by `var.cidr`
- **Two public subnets** in different Availability Zones (`ap-south-1a` & `ap-south-1b`)
- **Internet Gateway** and **Route Table** to enable internet access
- **Security Group** allowing:
  - HTTP (80) from anywhere
  - SSH (22) from anywhere
  - All outbound traffic
- **Two EC2 instances** (Amazon Linux AMI) with user data scripts
- **S3 bucket** for storage
- **Application Load Balancer (ALB)** with:
  - Target group
  - Listener on port 80
  - EC2 instances attached as targets
- **Output:** ALB DNS name

## 🛠 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed  
- AWS account with IAM user credentials  
- Configure AWS CLI:  

```bash
aws configure
