output "ecs_instance_public_ip" {
  description = "Public IP address of the ERPNext ECS instance"
  value       = alicloud_instance.erpnext_ecs.public_ip
}

output "oss_bucket_name" {
  description = "Name of the OSS bucket created for ERPNext"
  value       = alicloud_oss_bucket.erpnext_bucket.bucket
}

output "erpnext_url" {
  description = "URL to access the ERPNext site (assumes ERPNext runs on port 8000)"
  value       = "http://${alicloud_instance.erpnext_ecs.public_ip}:8000"
}

