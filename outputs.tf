output "project_name" {
  description = "Code Engine project name"
  value       = ibm_code_engine_project.auto_tagger_project.name
}

output "job_name" {
  description = "Name of the deployed job"
  value       = ibm_code_engine_job.auto_tagger_job.name
}

output "schedule_cli_command" {
  description = "CLI command to create the job schedule"
  value       = "ibmcloud target -r ${var.region} -g ${var.resource_group_name} && ibmcloud ce project select -n ${var.project_name} && ibmcloud ce subscription cron create --name ${var.job_name}-schedule --destination ${var.job_name} --schedule '${var.cron_expression}' --destination-type job --tz ${var.timezone}"
}

output "console_url" {
  description = "IBM Cloud console URL for the Code Engine project"
  value       = "https://cloud.ibm.com/containers/serverless/project/${var.region}/${ibm_code_engine_project.auto_tagger_project.project_id}/overview"
} 