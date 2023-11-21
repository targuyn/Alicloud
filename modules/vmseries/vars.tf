variable "name" {
  description = "firewall instance name"
}

variable "mgmt_vswitch" {}
variable "mgmt_sg" {}
variable "mgmt_ip" {}
variable "untrust_vswitch" {}
variable "untrust_sg" {}
variable "untrust_ip" {}
variable "trust_vswitch" {}
variable "trust_sg" {}
variable "trust_ip" {}
variable "ha_vswitch" {}
variable "ha_sg" {}
variable "zone" {}
variable "instance_type" {}
variable "image_id" {}
variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "fw_user_data" {}
variable "bootstrap" {}
variable "key_name" {}
variable "disk_category" {}
variable "res_group" {}

