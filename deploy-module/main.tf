terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0.0"
    }
  }
}

provider "google" {
  # Configuration options
}

variable "gcp_sink_resource_id" {
  type        = string
  description = "Where the log sink will be created, it could be projectID, folderID, organizationID"
  nullable    = false
}

variable "gcp_sink_resource_type" {
  type        = string
  description = "Where the log sink will be created, it could be project, folder or organization"
  nullable    = false
}

variable "gcp_destination_project_id" {
  type        = string
  description = "Which project the raw data BigQuery dataset will be located"
  nullable    = false
}

variable "gcp_destination_dataset_id" {
  type        = string
  description = "Name the raw data BigQuery dataset"
  nullable    = false
}

module "log_export" {
  source          = "terraform-google-modules/log-export/google"
  destination_uri = module.destination.destination_uri
  bigquery_options = {
    use_partitioned_tables = true
  }
  filter                 = <<EOT
    protoPayload.metadata.@type="type.googleapis.com/google.cloud.audit.BigQueryAuditMetadata" OR
    protoPayload.methodName =~ ".*(Set|set)Iam.*" OR
    (protoPayload.serviceName="serviceusage.googleapis.com" AND resource.type="audited_resource" AND protoPayload.methodName =~ ".*EnableService.*") OR
    (protoPayload.serviceName="compute.googleapis.com" AND resource.type="gce_firewall_rule" AND protoPayload.methodName =~ "v1.compute.firewalls.*") OR
    (protoPayload.serviceName="iam.googleapis.com" AND resource.type="service_account" AND protoPayload.methodName =~ ".*CreateServiceAccount.*") OR
    (logName:("logs/cloudaudit.googleapis.com%2Fsystem_event" OR "logs/cloudaudit.googleapis.com%2Factivity") AND resource.type="gce_instance")
  EOT
  log_sink_name          = "eventd_auditlog_bigquery"
  parent_resource_id     = var.gcp_sink_resource_id
  parent_resource_type   = var.gcp_sink_resource_type
  unique_writer_identity = true
}

module "destination" {
  source                   = "terraform-google-modules/log-export/google//modules/bigquery"
  project_id               = var.gcp_destination_project_id
  dataset_name             = var.gcp_destination_dataset_id
  log_sink_writer_identity = module.log_export.writer_identity
}
