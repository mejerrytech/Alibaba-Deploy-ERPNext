terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.244.0"
    }
  }
}

provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "alicloud_zones" "available" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "erpnext_vpc" {
  vpc_name   = "erpnext-vpc"
  cidr_block = var.vpc_cidr
}

resource "alicloud_vswitch" "erpnext_vswitch" {
  vswitch_name = "erpnext-vswitch"
  cidr_block   = cidrsubnet(var.vpc_cidr, 8, 1)
  vpc_id       = alicloud_vpc.erpnext_vpc.id
  zone_id      = data.alicloud_zones.available.zones[0].id
}

resource "alicloud_security_group" "erpnext_sg" {
  vpc_id              = alicloud_vpc.erpnext_vpc.id
  security_group_name = "erpnext-sg"
}

resource "alicloud_security_group_rule" "allow_common_ports" {
  for_each = toset(["22", "80", "443", "8000"])
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "${each.value}/${each.value}"
  priority          = 1
  security_group_id = alicloud_security_group.erpnext_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "erpnext_ecs" {
  instance_name              = "erpnext-ecs"
  instance_type              = var.ecs_instance_type
  image_id                   = "ubuntu_22_04_x64_20G_alibase_20250415.vhd"
  vswitch_id                 = alicloud_vswitch.erpnext_vswitch.id
  security_groups            = [alicloud_security_group.erpnext_sg.id]
  system_disk_category       = "cloud_essd"
  system_disk_size           = 100
  internet_max_bandwidth_out = 20
  password                   = var.ecs_password
  allocate_public_ip         = true

  depends_on = [
    alicloud_oss_bucket.erpnext_bucket
  ]
}

resource "alicloud_oss_bucket" "erpnext_bucket" {
  bucket = "erpnext-files-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "alicloud_oss_bucket_acl" "erpnext_bucket_acl" {
  bucket = alicloud_oss_bucket.erpnext_bucket.id
  acl    = "private"
}

resource "null_resource" "provision_erpnext" {
  depends_on = [alicloud_instance.erpnext_ecs]

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ecs_password
    host     = alicloud_instance.erpnext_ecs.public_ip
  }

  provisioner "file" {
    source      = "erpnext_install.sh"
    destination = "/tmp/erpnext_install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/erpnext_install.sh",
      "sudo bash /tmp/erpnext_install.sh"
    ]
  }
}