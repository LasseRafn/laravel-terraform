# Your AWS CLI profile
aws_profile = "default"

# The default region for your Terraform infrastructure
aws_region = "eu-central-1"

# Your project's name
stack_name = "rackbeat"

# Optional Elastic IPs you want to use
public_ips = {
  production = "18.194.29.93"
  default = "18.194.29.93"
}

# EC2 instances
number_of_instances = 3

# RDS
rds_instance_class = "db.t2.medium"
rds_allocated_storage = 100
