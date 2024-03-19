# Create Docker provider/resource for Terraform Cloud (TFC)
terraform {
  cloud {
    organization = "keeganwalsh"

    workspaces {
      name = "terraform-cli-example"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Start of Serverless Jenkins
provider "aws" {
  region                   = "us-west-2"
  profile                  = "aws"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  # assume_role {
  #   role_arn     = "arn:aws:iam::090334723359:role/terraform-cloud-assume-role"
  #   session_name = "VPEngineeringSession"
  #   external_id  = "VPEngineering"
  # }
}

module "serverless-jenkins" {
  source  = "TheNageek/serverless-jenkins/aws"
  version = "0.5.0"

  vpc_id                = "vpc-03a6a84c4ca2a17dd"
  public_subnets        = ["subnet-0a68ccafccaa2c745", "subnet-06f0e1e9d32152380"]
  private_subnets       = ["subnet-049536fff4d9d043f", "subnet-01e3d319aae921484"]
  assign_public_ip      = true
  create_private_subnet = false

  jenkins_controller_cpu      = 512
  jenkins_controller_memory   = 4096
  jenkins_agents_cpu          = 16384
  jenkins_agents_memory_limit = 0

  alb_protocol = "HTTPS"
  alb_policy_ssl      = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  alb_certificate_arn = "arn:aws:acm:us-west-2:090334723359:certificate/6cf0ad1e-6672-4003-8bc1-e338d7d05b16"

  route53_create_alias = true
  route53_zone_id      = "Z033006339CRNM8DJNOED"
  route53_alias_name   = "jenkins"

  tags = {
    Module = "Serverless_Jenkins"
  }
}