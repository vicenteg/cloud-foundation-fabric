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

# output "ext_ip_address" {
#   description = "External IP address"
#   value       = var.ext_lb_config != null && length(local.ext_instances) > 0 ? module.ext_lb[0].ip_address : null
# }

# output "int_ip_addresses" {
#   description = "Internal IP addresses"
#   value       = var.int_lb_config != null && length(local.int_instances) > 0 ? { for k, v in module.int_lb : k => v.address } : null
# }

# output "int_cross_region_ip_addresses" {
#   description = "Internal IP addresses"
#   value       = var.int_cross_region_lb_config != null && length(local.int_cross_region_instances) > 0 ? module.int_cross_region_lb.addresses : null
# }

output "project_id" {
  description = "Project."
  value       = module.project.project_id
}

output "apigee_vpc" {
  description = "Local network, if created."
  value       = try(var.network_config.apigee_vpc.auto_create, false) ? module.apigee_vpc[0] : null
}

output "instance_service_attachments" {
  description = "Instance service attachments."
  value       = { for k, v in module.apigee.instances : k => v.service_attachment }
}

output "endpoint_attachment_hosts" {
  description = "Endpoint attachment hosts."
  value       = module.apigee.endpoint_attachment_hosts
}
