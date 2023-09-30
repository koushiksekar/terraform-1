terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  region = var.region
}


# terraform {
#   required_providers {
#     github = {
#       source = "integrations/github"
#       version = "5.38.0"
#     }
#   }
# }

# provider "github" {
#   token = ""
# }
