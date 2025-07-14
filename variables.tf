variable "region" {
  description = "IBM Cloud region for deployment"
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Resource group ID for the Code Engine project (lowercase letters and numbers only)"
  type        = string
  default     = "auto-tagger"
}

variable "project_name" {
  description = "Name of the Code Engine project"
  type        = string
  default     = "auto-tagger"
}

variable "job_name" {
  description = "Name of the serverless job"
  type        = string
  default     = "auto-tagger-job"
}

variable "container_image" {
  description = "Container image for the job"
  type        = string
  default     = "quay.io/cloud-governance/cloud-governance:latest"
}

variable "cron_expression" {
  description = "Cron expression for job scheduling (daily)"
  type        = string
  default     = "0 0 */1 * *"
}

variable "timezone" {
  description = "Timezone for the cron schedule"
  type        = string
  default     = "UTC"
}

variable "cpu_limit" {
  description = "CPU limit for the job"
  type        = string
  default     = "0.125"
}

variable "memory_limit" {
  description = "Memory limit for the job"
  type        = string
  default     = "250M"
}

variable "retry_limit" {
  description = "Number of retry attempts for failed jobs"
  type        = number
  default     = 3
}

variable "secret_data" {
  description = "Sensitive configuration data for the secret"
  type        = map(string)
  sensitive   = true
}

variable "config_data" {
  description = "Non-sensitive configuration data for the configmap"
  type        = map(string)
}

variable "service_id_name" {
  description = "Name for the Service ID used by the auto-tagger job"
  type        = string
  default     = "auto-tagger"
}
