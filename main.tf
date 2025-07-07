



# Azure Provider



/* provider "azurerm" {
  subscription_id = "88892b4f-5dd9-4cb9-8465-216794938557"    
  features {}
}

# Create a resource group

resource "azurerm_resource_group" "example" {
  name     = "terraform-azure-test-rg"
  location = "Central India" 
}
 */


 # Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Choose your desired AWS region
}


# --- Terraform Cloud Backend Configuration ---
terraform {
  required_version = "~> 1.8.0" # Use a recent Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  cloud {
    organization = "terraform-realtime" # <<-- IMPORTANT: Replace with your TFC Org Name

    workspaces {
      name = "my-s3-website-workspace" # <<-- IMPORTANT: Choose a unique name for your TFC Workspace
    }
  }
}

# --- End Terraform Cloud Backend Configuration ---

# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "website_bucket" {
  bucket = "terraform-s3-git-actions" # <<-- IMPORTANT: Choose a globally unique S3 bucket name
  # Removed deprecated 'acl' argument. Public access is managed via aws_s3_bucket_public_access_block.

  tags = {
    Environment = "Production"
    Project     = "MyS3Website"
  }
}

resource "aws_s3_bucket_website_configuration" "website_bucket_website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Allow public access for static website hosting
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

# S3 Bucket Policy to allow public read for website content
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
      }
    ]
  })
}


# Upload local application files to S3
resource "aws_s3_bucket_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key       = "index.html"
  source       = "C://terraform//terraform-project//.terraform//providers//registry.terraform.io//hashicorp//index.html" # Path to your local index.html
  content_type = "text/html"
  acl          = "public-read"
  etag         = filemd5("C://terraform//terraform-project//.terraform//providers//registry.terraform.io//hashicorp//index.html") # Forces re-upload on file change
}


# You would add more aws_s3_bucket_object resources for other files (CSS, JS, etc.)
# Or use a local-exec provisioner with aws s3 sync or a Terraform module for S3 sync.
# For a simple example, let's keep it to index.html.

output "website_endpoint" {
  description = "The S3 website endpoint"
  value       = aws_s3_bucket.website_bucket.website_endpoint
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
}

