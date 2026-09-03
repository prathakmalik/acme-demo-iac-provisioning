terraform {
  backend "s3" {
    bucket = "fit-dia-terraform-state"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}
