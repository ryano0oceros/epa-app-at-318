terraform {
  backend "s3" {
    bucket = "ryano0oceros-epa-demo-bucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
