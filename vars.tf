variable "access_key" {}

variable "secret_key" {}

variable "region" {
  default = "ap-southeast-1"
}

variable "fw-vpc" {
  default = "FW-VPC"
}

variable "fw-vpc-cidr" {
  default = "10.104.0.0/16"
}

variable "ha-vswitch-cidr-zone1" {
  default = "10.104.5.0/24"
}

variable "ha-vswitch-cidr-zone2" {
  default = "10.104.6.0/24"
}

variable "zone1-vswitch-mgmt-cidr" {
  default = "10.104.1.0/24"
}

variable "zone1-vswitch-untrust-cidr" {
  default = "10.104.3.0/24"
}

variable "zone1-vswitch-trust-cidr" {
  default = "10.104.2.0/24"
}

variable "zone2-vswitch-mgmt-cidr" {
  default = "10.104.11.0/24"
}

variable "zone2-switch-untrust-cidr" {
  default = "10.104.13.0/24"
}

variable "zone2-vswitch-trust-cidr" {
  default = "10.104.12.0/24"
}

variable "server1-vswitch-cidr" {
  default = "10.104.4.0/24"
}

# variable "server2-vswitch-cidr" {
#   default = "10.104.12.0/24"
# }

variable "instance-type" {
  default = "ecs.g5.xlarge"
}

variable "instance1-name" {
  default = "FW1-VM"
}

variable "instance2-name" {
  default = "FW2-VM"
}

variable "instance3-name" {
  default = "FW3-VM"
}

variable "FW1-MGMT-IP" {
  default = "10.104.1.10"
}

variable "FW1-UNTRUST-IP" {
  default = "10.104.3.22"
}

variable "FW1-TRUST-IP" {
  default = "10.104.2.10"
}


variable "FW2-MGMT-IP" {
  default = "10.104.1.11"
}

variable "FW2-UNTRUST-IP" {
  default = "10.104.3.23"
}

variable "FW2-TRUST-IP" {
  default = "10.104.2.11"
}

variable "FW3-MGMT-IP" {
  default = "10.104.11.10"
}

variable "FW3-UNTRUST-IP" {
  default = "10.104.13.86"
}

variable "FW3-TRUST-IP" {
  default = "10.104.12.13"
}

variable "Server1-IP" {
  default = "10.104.4.30"
}

variable "Server1-Name" {
  default = "Server1"
}

variable "Server2-IP" {
  default = "10.104.4.40"
}

variable "Server2-Name" {
  default = "Server2"
}

variable "linux_instance_type" {
  default = "ecs.n1.tiny"
}

variable "linux_password" {
  default = "PaloAlt0123"
}

variable "panos_version" {
  default = "11.0.0"
}

variable "image_id" {}

variable "ssh_key_path" {}

variable "bootstrap" {}

variable "auth_code" {}

variable "key_name" {}

variable "disk_category" {
  default = "cloud_essd"
}

variable "disable_dpdk" {
  type = bool
  default = false
}

variable "res_group" {}
