module "fw1" {
  source = "./modules/vmseries/"
  name   = var.instance1-name

  mgmt_vswitch = alicloud_vswitch.zone1-vswitch-mgmt.id
  mgmt_sg      = [alicloud_security_group.FW-MGMT-SG.id]
  mgmt_ip      = var.FW1-MGMT-IP

  untrust_vswitch = alicloud_vswitch.zone1-vswitch-untrust.id
  untrust_sg      = [alicloud_security_group.FW-DATA-SG.id]
  untrust_ip      = var.FW1-UNTRUST-IP

  trust_vswitch = alicloud_vswitch.zone1-vswitch-trust.id
  trust_sg      = [alicloud_security_group.FW-DATA-SG.id]
  trust_ip      = var.FW1-TRUST-IP

  ha_vswitch = alicloud_vswitch.zone1-vswitch-ha.id
  ha_sg      = [alicloud_security_group.FW-DATA-SG.id]

  zone = data.alicloud_zones.fw-zone.zones[0].id

  instance_type = var.instance-type
  disk_category = var.disk_category

  image_id = data.alicloud_images.vmseries.images[0].id

  res_group    = var.res_group

  key_name   = var.key_name
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  bootstrap    = var.bootstrap
  fw_user_data = local.fw1_user_data
}

module "fw2" {
  source = "./modules/vmseries/"
  name   = var.instance2-name

  mgmt_vswitch = alicloud_vswitch.zone1-vswitch-mgmt.id
  mgmt_sg      = [alicloud_security_group.FW-MGMT-SG.id]
  mgmt_ip      = var.FW2-MGMT-IP

  untrust_vswitch = alicloud_vswitch.zone1-vswitch-untrust.id
  untrust_sg      = [alicloud_security_group.FW-DATA-SG.id]
  untrust_ip      = var.FW2-UNTRUST-IP

  trust_vswitch = alicloud_vswitch.zone1-vswitch-trust.id
  trust_sg      = [alicloud_security_group.FW-DATA-SG.id]
  trust_ip      = var.FW2-TRUST-IP

  ha_vswitch = alicloud_vswitch.zone1-vswitch-ha.id
  ha_sg      = [alicloud_security_group.FW-DATA-SG.id]

  zone = data.alicloud_zones.fw-zone.zones[0].id

  instance_type = var.instance-type
  disk_category = var.disk_category

  image_id = data.alicloud_images.vmseries.images[0].id

  res_group    = var.res_group

  key_name   = var.key_name
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  bootstrap    = var.bootstrap
  fw_user_data = local.fw2_user_data
}

module "fw3" {
  source = "./modules/vmseries/"
  name   = var.instance3-name

  mgmt_vswitch = alicloud_vswitch.zone2-vswitch-mgmt.id
  mgmt_sg      = [alicloud_security_group.FW-MGMT-SG.id]
  mgmt_ip      = var.FW3-MGMT-IP

  untrust_vswitch = alicloud_vswitch.zone2-vswitch-untrust.id
  untrust_sg      = [alicloud_security_group.FW-DATA-SG.id]
  untrust_ip      = var.FW3-UNTRUST-IP

  trust_vswitch = alicloud_vswitch.zone2-vswitch-trust.id
  trust_sg      = [alicloud_security_group.FW-DATA-SG.id]
  trust_ip      = var.FW3-TRUST-IP

  ha_vswitch = alicloud_vswitch.zone2-vswitch-ha.id
  ha_sg      = [alicloud_security_group.FW-DATA-SG.id]

  zone = data.alicloud_zones.fw-zone.zones[1].id

  instance_type = var.instance-type
  disk_category = var.disk_category

  image_id = data.alicloud_images.vmseries.images[0].id

  res_group    = var.res_group

  key_name   = var.key_name
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  bootstrap    = var.bootstrap
  fw_user_data = local.fw3_user_data
}
