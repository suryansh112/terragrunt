terraform {
  backend "s3" {
    bucket = var.s3_bucket
    region = var.region
    key    = var.key
  }
}