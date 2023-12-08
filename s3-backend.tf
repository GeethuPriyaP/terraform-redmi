terraform {
  backend "s3" {
    bucket = "terraform-git-redmi.mikhaelnoah.online"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

