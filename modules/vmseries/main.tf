terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.206.0"
    }
  }
}

# Configure the Alicloud Provider
provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Create Untrust Interface
resource "alicloud_network_interface" "fw-eni1" {
  network_interface_name = "${var.name}-eni1"
  vswitch_id             = var.untrust_vswitch
  primary_ip_address     = var.untrust_ip
  security_group_ids     = var.untrust_sg
}

# Create Trust Interface
resource "alicloud_network_interface" "fw-eni2" {
  network_interface_name = "${var.name}-eni2"
  vswitch_id             = var.trust_vswitch
  primary_ip_address     = var.trust_ip
  security_group_ids     = var.trust_sg
}

# Create HA Interface
resource "alicloud_network_interface" "ha" {
  network_interface_name = "${var.name}-eni3"
  vswitch_id             = var.ha_vswitch
  security_group_ids     = var.ha_sg
}

# Launch Instance with Mgmt Interface
resource "alicloud_instance" "vmseries" {
  availability_zone          = var.zone
  security_groups            = var.mgmt_sg
  resource_group_id          = var.res_group
  instance_type              = var.instance_type
  system_disk_size           = 60
  system_disk_category       = var.disk_category
  system_disk_name           = "${var.name}-disk0"
  image_id                   = var.image_id
  instance_name              = var.name
  vswitch_id                 = var.mgmt_vswitch
  internet_max_bandwidth_out = 50
  private_ip                 = var.mgmt_ip
  host_name                  = var.name
  key_name                   = var.key_name

  #instance_charge_type = "PrePaid"

  user_data = var.bootstrap == "yes" ? var.fw_user_data : ""
}

# Attach Untrust interface to Instance
resource "alicloud_network_interface_attachment" "fw-untrust" {
  instance_id          = alicloud_instance.vmseries.id
  network_interface_id = alicloud_network_interface.fw-eni1.id
}

# Attach Trust interface to Instance
resource "alicloud_network_interface_attachment" "fw-trust" {
  instance_id          = alicloud_instance.vmseries.id
  network_interface_id = alicloud_network_interface.fw-eni2.id

  depends_on = [
    alicloud_network_interface_attachment.fw-untrust,
  ]
}

# Attach HA interface to Instance
resource "alicloud_network_interface_attachment" "ha" {
  instance_id          = alicloud_instance.vmseries.id
  network_interface_id = alicloud_network_interface.ha.id

  depends_on = [
    alicloud_network_interface_attachment.fw-trust,
  ]
}