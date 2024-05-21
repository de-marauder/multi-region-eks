terraform {
  required_version = ">= 1.8"
}

provider "aws" {
  region = var.region
  alias = "provider"
}