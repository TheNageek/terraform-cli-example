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

  vpc_id                = "vpc-08f99007f40f672d5"
  public_subnets        = ["subnet-0fe5db33a329d573a", "subnet-0efef07aded8f23e2"]
  private_subnets       = ["subnet-0159622f96c25ba89", "subnet-020e05cdaea8b9e20"]
  assign_public_ip      = false
  create_private_subnet = true
  private_subnet_cidr   = "10.0.5.0/24"
  natg_public_subnet    = "subnet-0fe5db33a329d573a"

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