variable "stack_name" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable "number_of_instances" {
  type = "integer"
}

variable "public_ips" {
  type = "map"
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "~> 1.9"
}

terraform {
  backend "s3" {
    bucket  = "rackbeat-tf-state"
    key     = "main.tfstate"
    region  = "${var.aws_region}"
    profile = "default"
    workspace_key_prefix  = "workspaces"
  }
}

// vpc
module "vpc" {
  source     = "./modules/vpc"
  stack_name = "${var.stack_name}"
}

// database
module "aurora" {
  source             = "./modules/aurora"
  stack_name         = "${var.stack_name}"
  subnet_ids         = "${module.vpc.public_subnet_ids}"
  vpc_id             = "${module.vpc.vpc_id}"
  allocated_storage  = "${var.rds_allocated_storage}"
  instance_class     = "${var.instance_class}"
}

######
# ELB
######
module "elb" {
  source = "./modules/elb"

  load_balancer_type = "application"
  name = "${var.stack_name}"

  subnets         = ["${module.vpc.public_subnet_ids}"]
  security_groups = ["${var.security_groups}"]
  internal        = false
  
  vpc_id           = "${module.vpc.vpc_id}"
  public_subnet_id = "${module.vpc.public_subnet_ids[0]}"
  public_ips       = "${var.public_ips}"
  s3_bucket_arn    = "${module.s3.s3_bucket_arn}"

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener     = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = "8080"
      instance_protocol = "HTTP"
      lb_port           = "8080"
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = "443"
      instance_protocol = "HTTPS"
      lb_port           = "443"
      lb_protocol       = "HTTPS"
      ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
    },
  ]
  
  access_logs  = [
      {
        bucket = "${module.s3_logs.s3_bucket_arn}",
        prefix  = "access_logs"
        enabled = true
        interval      = 60
      },
  ]
  
  health_check = [
    {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
    {
      target              = "HTTP:443/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ],
  
  tags = {
    name = "${var.stack_name}"
  }
}

#################
# ELB attachment
#################
module "elb_attachment" {
  source = "./modules/elb_attachment"

  number_of_instances = "${var.number_of_instances}"

  elb       = "${module.elb.this_elb_id}"
  instances = "${var.instances}"
}

// vm
//module "ec2" {
//  source           = "./modules/ec2"
//  stack_name       = "${var.stack_name}"
//  vpc_id           = "${module.vpc.vpc_id}"
//  public_subnet_id = "${module.vpc.public_subnet_ids[0]}"
//  public_ips       = "${var.public_ips}"
//  s3_bucket_arn    = "${module.s3.s3_bucket_arn}"
//}

module "s3" {
  source           = "./modules/s3"
  stack_name       = "${var.stack_name}"
}

module "s3_logs" {
  source           = "./modules/s3"
  stack_name       = "${var.stack_name}-logs"
}

