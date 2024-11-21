variable "project_id" {
  description = "The ID of the project to use"
  type        = string
}

variable "organization_id" {
  description = "The ID of the organization"
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
}
