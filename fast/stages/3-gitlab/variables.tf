/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# defaults for variables marked with global tfdoc annotations, can be set via
# the tfvars file generated in stage 00 and stored in its outputs

variable "automation" {
  # tfdoc:variable:source 0-bootstrap
  description = "Automation resources created by the bootstrap stage."
  type        = object({
    outputs_bucket               = string
    project_id                   = string
    project_number               = string
    federated_identity_pool      = string
    federated_identity_providers = map(object({
      audiences        = list(string)
      issuer           = string
      issuer_uri       = string
      name             = string
      principal_branch = string
      principal_repo   = string
    }))
    service_accounts = object({
      resman-r = string
    })
  })
}

variable "billing_account" {
  # tfdoc:variable:source 0-bootstrap
  description = "Billing account id. If billing account is not part of the same org set `is_org_level` to `false`. To disable handling of billing IAM roles set `no_iam` to `true`."
  type        = object({
    id           = string
    is_org_level = optional(bool, true)
    no_iam       = optional(bool, false)
  })
  nullable = false
}

variable "folder_ids" {
  # tfdoc:variable:source 1-resman
  description = "Folder to be used for the gitlab resources in folders/nnnn format."
  type        = object({
    gitlab = string
  })
}

variable "gitlab_config" {
  type = object({
    hostname = optional(string, "gitlab.gcp.example.com")
    mail     = optional(object({
      enabled  = optional(bool, false)
      sendgrid = optional(object({
        api_key        = optional(string)
        email_from     = optional(string, null)
        email_reply_to = optional(string, null)
      }), null)
    }), {})
    saml = optional(object({
      forced                 = optional(bool, false)
      idp_cert_fingerprint   = string
      sso_target_url         = string
      name_identifier_format = optional(string, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress")
    }), null)
    ha_required = optional(bool, false)
  })
  default = {}
}

variable "gitlab_runners_config" {
  description = "Gitlab Runners configuration"
  type        = object({
    enable       = optional(bool, false)
    architecture = optional(string, "CENTRALIZED")
    tokens       = optional(object({
      landing = optional(string, null)
      dev     = optional(string, null)
      prod    = optional(string, null)
    }))
    instance_type = optional(string, "n2-standard-2")
    name          = optional(string, "gitlab-runner")
    network_tags  = optional(list(string), [])
  })

  validation {
    condition     = var.gitlab_runners_config.architecture == "CENTRALIZED" || var.gitlab_runners_config.architecture == "DISTRIBUTED"
    error_message = "Error in the provided architecture, only 'CENTRALIZED' or 'DISTRIBUTED' values are supported."
  }
  validation {
    condition     = (var.gitlab_runners_config.architecture == "CENTRALIZED" && try(var.gitlab_runners_config.tokens.landing != null, false)) || (var.gitlab_runners_config.architecture == "DISTRIBUTED" && try(var.gitlab_runners_config.tokens.dev != null, false) && try(var.gitlab_runners_config.tokens.prod != null, false))
    error_message = "'CENTRALIZED' architecture requires 'landing' token for registering runners."
  }

  default = { enable = false }
}

variable "host_project_ids" {
  type = object({
    dev-spoke-0  = string
    prod-landing = string
  })
}

variable "locations" {
  # tfdoc:variable:source 0-bootstrap
  description = "Optional locations for GCS, BigQuery, and logging buckets created here."
  type        = object({
    bq      = string
    gcs     = string
    logging = string
    pubsub  = list(string)
  })
  nullable = false
}

variable "outputs_location" {
  description = "Path where providers and tfvars files for the following stages are written. Leave empty to disable."
  type        = string
  default     = null
}

variable "prefix" {
  type = string
}

variable "regions" {
  description = "Region definitions."
  type        = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "europe-west1"
    secondary = "europe-west4"
  }
}

variable "service_accounts" {
  # tfdoc:variable:source 1-resman
  description = "Automation service accounts in name => email format."
  type        = object({
    data-platform-dev    = string
    data-platform-prod   = string
    gitlab               = string
    gke-dev              = string
    gke-prod             = string
    project-factory-dev  = string
    project-factory-prod = string
  })
  default = null
}

variable "subnet_self_links" {
  # tfdoc:variable:source 2-networking
  description = "Shared VPC subnet self links."
  type        = object({
    dev-spoke-0  = map(string)
    prod-landing = map(string)
  })
  default = null
}

variable "vpc_self_links" {
  # tfdoc:variable:source 2-networking
  description = "Shared VPC self links."
  type        = object({
    dev-spoke-0  = string
    prod-landing = string
  })
  default = null
}
