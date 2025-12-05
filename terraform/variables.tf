variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name. AWS Academy default key in us-east-1 is usually 'vockey'. Override if different."
  type        = string
  default     = "vockey"
}

variable "use_existing_vpc" {
  description = "Whether to use existing VPC (for AWS Academy)"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID (required if use_existing_vpc is true)"
  type        = string
  default     = ""
}

variable "existing_subnet_ids" {
  description = "Existing subnet IDs (required if use_existing_vpc is true)"
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID"
  type        = string
  # Amazon Linux 2 AMI for us-east-1 (update if needed)
  default     = "ami-0c02fb55956c7d316"
}

variable "ssh_user" {
  description = "SSH username for AMI (ec2-user for Amazon Linux 2)"
  type        = string
  default     = "ec2-user"
}

