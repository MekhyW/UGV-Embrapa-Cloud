variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "ros2-robot"
}

variable "thing_name" {
  description = "Name of the IoT thing"
  type        = string
  default     = "ros2-robot"
}

variable "shadow_name" {
  description = "Name of the IoT shadow"
  type        = string
  default     = "robot_state"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "development"
}

variable "repository_url" {
  description = "GitHub repository URL for the Amplify app"
  type        = string
  default     = "https://github.com/MekhyW/UGV-Embrapa-Cloud"
}

variable "github_access_token" {
  description = "GitHub access token for Amplify"
  type        = string
  sensitive   = true
}