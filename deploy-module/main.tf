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

module "log_export" {
  source                 = "terraform-google-modules/log-export/google"
  destination_uri        = module.destination.destination_uri
  filter                 = <<EOT
    protoPayload.metadata.@type="type.googleapis.com/google.cloud.audit.BigQueryAuditMetadata" OR
    protoPayload.methodName =~ ".*(Set|set)Iam.*" OR
    (protoPayload.serviceName="serviceusage.googleapis.com" AND resource.type="audited_resource" AND protoPayload.methodName =~ ".*EnableService.*") OR
    (protoPayload.serviceName="compute.googleapis.com" AND resource.type="gce_firewall_rule" AND protoPayload.methodName =~ "v1.compute.firewalls.*") OR
    (protoPayload.serviceName="iam.googleapis.com" AND resource.type="service_account" AND protoPayload.methodName =~ ".*CreateServiceAccount.*") OR
    (logName:("logs/cloudaudit.googleapis.com%2Fsystem_event" OR "logs/cloudaudit.googleapis.com%2Factivity") AND resource.type="gce_instance")
  EOT
  log_sink_name          = "eventd_auditlog_bigquery"
  parent_resource_id     = "gcp-expert-sandbox-browny"
  parent_resource_type   = "project"
  unique_writer_identity = true
}

module "destination" {
  source                   = "terraform-google-modules/log-export/google//modules/bigquery"
  project_id               = "gcp-expert-sandbox-browny"
  dataset_name             = "eventd_auditlog"
  log_sink_writer_identity = module.log_export.writer_identity
}
