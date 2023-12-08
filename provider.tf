provider "aws" {
  region = var.region
  default_tags {
    tags = {
     Environment = var.project_env
     Project     = var.project_name
   }
  }
}
