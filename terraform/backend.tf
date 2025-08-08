terraform {
  backend "s3" {
    bucket  = "devopsbackend-new"
    key     = "terraform/django-nextjs-app/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
