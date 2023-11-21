
resource "alicloud_vpc_ha_vip" "untrust-havip" {
  description = "Untrust-HAVIP"
  vswitch_id  = alicloud_vswitch.zone1-vswitch-untrust.id
  ha_vip_name = "Untrust-HAVIP"
  ip_address  = "10.104.3.100"
  resource_group_id    = var.res_group
}

resource "alicloud_eip" "havip-eip" {
  address_name         = "havip-eip"
  description          = "EIP assigned to the Untrust HAVIP"
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  resource_group_id    = var.res_group
}

resource "alicloud_eip_association" "havip_eip_asso" {
  allocation_id = alicloud_eip.havip-eip.id
  instance_id   = alicloud_vpc_ha_vip.untrust-havip.id
  instance_type = "HaVip"
  force         = true
}

resource "alicloud_havip_attachment" "fw1-untrust" {
  havip_id      = alicloud_vpc_ha_vip.untrust-havip.id
  instance_id   = module.fw1.eni-untrust
  instance_type = "NetworkInterface"
  force         = "True"

  depends_on = [
    module.fw1.eni-untrust-attach
  ]
}

resource "alicloud_havip_attachment" "fw2-untrust" {
  havip_id      = alicloud_vpc_ha_vip.untrust-havip.id
  instance_id   = module.fw2.eni-untrust
  instance_type = "NetworkInterface"
  force         = "True"

  depends_on = [
    module.fw2.eni-untrust-attach
  ]
}

resource "alicloud_vpc_ha_vip" "trust-havip" {
  description = "Trust-HAVIP"
  vswitch_id  = alicloud_vswitch.zone1-vswitch-trust.id
  ha_vip_name = "Trust-HAVIP"
  ip_address  = "10.104.2.100"
  resource_group_id    = var.res_group
}

resource "alicloud_havip_attachment" "fw1-trust" {
  havip_id      = alicloud_vpc_ha_vip.trust-havip.id
  instance_id   = module.fw1.eni-trust
  instance_type = "NetworkInterface"
  force         = "True"

  depends_on = [
    module.fw1.eni-trust-attach
  ]
}

resource "alicloud_havip_attachment" "fw2-trust" {
  havip_id      = alicloud_vpc_ha_vip.trust-havip.id
  instance_id   = module.fw2.eni-trust
  instance_type = "NetworkInterface"
  force         = "True"

  depends_on = [
    module.fw2.eni-trust-attach
  ]
}
