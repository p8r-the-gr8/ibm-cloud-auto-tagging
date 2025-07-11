provider "ibm" {
  region = var.region
}

# Convert the resource tags to work for the CE Project
locals {
  # This also trims any whitespace around the tags
  tags = [
    for tag in split(",", var.config_data["IBM_CUSTOM_TAGS_LIST"]) : 
    trimspace(tag)
  ]
}

# Resource Group
resource "ibm_resource_group" "auto_tagger_resource_group" {
  name = var.resource_group_name
}

# Code Engine Project
resource "ibm_code_engine_project" "auto_tagger_project" {
  name              = var.project_name
  resource_group_id = ibm_resource_group.auto_tagger_resource_group.id
}

# Tag the Code Engine Project
resource "ibm_resource_tag" "auto_tagger_project_tags" {
    resource_id = ibm_code_engine_project.auto_tagger_project.crn
    tags        = local.tags
}

# Secret for sensitive configuration
resource "ibm_code_engine_secret" "auto_tagger_secret" {
  project_id = ibm_code_engine_project.auto_tagger_project.project_id
  name       = "${var.job_name}-secret"
  format     = "generic"
  data       = var.secret_data
}

# ConfigMap for non-sensitive configuration
resource "ibm_code_engine_config_map" "auto_tagger_config" {
  project_id = ibm_code_engine_project.auto_tagger_project.project_id
  name       = "${var.job_name}-config"
  data       = var.config_data
}

# Job Definition
resource "ibm_code_engine_job" "auto_tagger_job" {
  project_id      = ibm_code_engine_project.auto_tagger_project.project_id
  name            = var.job_name
  image_reference = var.container_image
  
  # Resource allocation
  scale_cpu_limit      = var.cpu_limit
  scale_memory_limit   = var.memory_limit
  
  # Retry and timeout settings
  scale_retry_limit = var.retry_limit
  run_mode          = "task"

  # Environment variables from Secret
  run_env_variables {
    type      = "secret_full_reference"
    reference = ibm_code_engine_secret.auto_tagger_secret.name
  }

  # Environment variables from ConfigMap
  run_env_variables {
    type      = "config_map_full_reference"
    reference = ibm_code_engine_config_map.auto_tagger_config.name
  }
  
  depends_on = [
    ibm_code_engine_config_map.auto_tagger_config,
    ibm_code_engine_secret.auto_tagger_secret
  ]
}