module "server1" {
  source = "./modules/linux/"
  name   = var.Server1-Name

  server_vswitch = alicloud_vswitch.Server1-vswitch.id
  server_sg      = [alicloud_security_group.FW-DATA-SG.id]
  server_ip      = var.Server1-IP

  linux_instance_type = var.linux_instance_type

  image_id   = data.alicloud_images.ubuntu_image.images[0].id
  password   = var.linux_password
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  res_group    = var.res_group
}

module "server2" {
  source = "./modules/linux/"
  name   = var.Server2-Name

  server_vswitch = alicloud_vswitch.Server1-vswitch.id
  server_sg      = [alicloud_security_group.FW-DATA-SG.id]
  server_ip      = var.Server2-IP

  linux_instance_type = var.linux_instance_type

  image_id   = data.alicloud_images.ubuntu_image.images[0].id
  password   = var.linux_password
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  res_group    = var.res_group
}
