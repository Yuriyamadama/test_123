variable "project_id" {
  description = "The ID of the project to use"
  default = "glassy-iridium-438509-u8"
  type        = string
}

variable "region" {
  description = "Region for GCP services"
  type        = string
  default     = "us-central1"
}

variable "user_account" {
  description = "your user account"
  type        = string
  default = "tanishizuigao@gmail.com"
}

variable "github_repository" {
  description = "repo name"
  type        = string
  default = "Yuriyamadama/test_123"
}

variable "terraform_email" {
  description = "service account"
  type        = string
  default = "githubaction-for@glassy-iridium-438509-u8.iam.gserviceaccount.com"
}