variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "alb_sg_id"          { type = string }
variable "app_sg_id"          { type = string }
variable "key_name"           { type = string }

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID. If empty, latest Amazon Linux 2023 used."
  type        = string
  default     = ""
}
