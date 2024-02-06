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

resource "docker_image" "ubuntu" {
  name = "ubuntu:latest"
}

resource "docker_container" "ubuntu_container" {
  image             = docker_image.ubuntu.image_id
  name              = "ubuntu_container"
  must_run          = true
  publish_all_ports = true
  command = [
    "tail",
    "-f",
    "/dev/null"
  ]
}

# Start of Serverless Jenkins
provider "aws" {
  region                   = "us-west-2"
  profile                  = "aws"
  shared_credentials_files = ["/home/kwalsh/.aws/credentials"]
}

module "serverless-jenkins" {
  source  = "TheNageek/serverless-jenkins/aws"
  version = "0.2.0"

  vpc_id                = "vpc-03a6a84c4ca2a17dd"
  public_subnets        = ["subnet-0a68ccafccaa2c745", "subnet-06f0e1e9d32152380"]
  private_subnets       = ["subnet-049536fff4d9d043f", "subnet-01e3d319aae921484"]
  assign_public_ip      = false
  create_private_subnet = true
  private_subnet_cidr   = "10.0.5.0/24"
  natg_public_subnet    = "subnet-0a68ccafccaa2c745"

  alb_protocol = "HTTP"
  # alb_policy_ssl      = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  # alb_certificate_arn = var.certificate_arn

  route53_create_alias = true
  route53_zone_id      = "Z033006339CRNM8DJNOED"
  route53_alias_name   = "jenkins"

  jenkins_agents_cpu                         = 256
  jenkins_agents_memory_limit                = 1024
  jenkins_controller_cpu                     = 256
  jenkins_controller_memory                  = 1024
  jenkins_controller_task_log_retention_days = 30

  tags = {
    Module = "Serverless_Jenkins"
  }
}