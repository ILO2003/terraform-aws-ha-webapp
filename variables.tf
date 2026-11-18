variable "aws_region" {
  description = "Sets region in AWS provider properties"
  type        = string
  default     = "eu-north-1"
}
variable "cidr_block" {
  description = "cidr block for my ha-webapp-VPC"
  type        = string
  default     = "10.20.0.0/16"
}
variable "az_1" {
  description = "sets availability zone in my region"
  type        = string
  default     = "eu-north-1a"
}
variable "az_2" {
  description = "sets availability zone in my region"
  type        = string
  default     = "eu-north-1b"
}
variable "instance_type" {
  description = "instance type for my ha-webapp-template"
  type        = string
  default     = "t3.micro"
}