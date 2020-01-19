provider "aws" {
  region = "us-east-1"
}

module "ecs-cluster" {
    source = "./ecs-cluster"
}
