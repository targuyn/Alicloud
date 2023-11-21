resource "alicloud_vpc" "fw_vpc" {
  vpc_name    = "${var.fw-vpc}-${random_id.randomId.hex}"
  cidr_block  = var.fw-vpc-cidr
  description = "VPC for VM-Series on Alicloud"
  resource_group_id    = var.res_group
}

resource "alicloud_vswitch" "zone1-vswitch-mgmt" {
  vswitch_name = "zone1-vswitch-mgmt"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.zone1-vswitch-mgmt-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[0].id
  description  = "MGMT VSwitch for Zone 1 FW-VM"
}

resource "alicloud_vswitch" "zone1-vswitch-untrust" {
  vswitch_name = "zone1-vswitch-untrust"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.zone1-vswitch-untrust-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[0].id
  description  = "Untrust VSwitch for Zone 1 FW VM"
}

resource "alicloud_vswitch" "zone1-vswitch-trust" {
  vswitch_name = "zone1-vswitch-trust"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.zone1-vswitch-trust-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[0].id
  description  = "Trust VSwitch for Zone 1 FW VM"
}

resource "alicloud_vswitch" "zone2-vswitch-mgmt" {
  vswitch_name = "zone2-vswitch-mgmt"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.zone2-vswitch-mgmt-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[1].id
  description  = "MGMT VSwitch for Zone 2 FW VM"
}

resource "alicloud_vswitch" "zone2-vswitch-trust" {
  vswitch_name = "zone2-vswitch-trust"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.zone2-vswitch-trust-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[1].id
  description  = "Trust VSwitch for Zone 2 FW VM"
}

resource "alicloud_vswitch" "zone2-vswitch-untrust" {
  vswitch_name = "zone2-vswitch-untrust"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.zone2-switch-untrust-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[1].id
  description  = "Untrust VSwitch for Zone 2 FW VM"
}

resource "alicloud_vswitch" "zone1-vswitch-ha" {
  vswitch_name = "zone1-vswitch-ha"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.ha-vswitch-cidr-zone1
  zone_id      = data.alicloud_zones.fw-zone.zones[0].id
  description  = "HA VSwitch for Zone 1 FW VM"
}

resource "alicloud_vswitch" "zone2-vswitch-ha" {
  vswitch_name = "zone2-vswitch-ha"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.ha-vswitch-cidr-zone2
  zone_id      = data.alicloud_zones.fw-zone.zones[1].id
  description  = "HA VSwitch for Zone 2 FW VM"
}

resource "alicloud_vswitch" "Server1-vswitch" {
  vswitch_name = "Server1-VSwitch"
  vpc_id       = alicloud_vpc.fw_vpc.id
  cidr_block   = var.server1-vswitch-cidr
  zone_id      = data.alicloud_zones.fw-zone.zones[0].id
  description  = "VSwitch for Server1"
}

resource "alicloud_security_group" "FW-MGMT-SG" {
  name        = "FW-MGMT-Security-Group"
  vpc_id      = alicloud_vpc.fw_vpc.id
  description = "Security Group for FW MGMT"
}

resource "alicloud_security_group_rule" "allow_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.FW-MGMT-SG.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_https" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = alicloud_security_group.FW-MGMT-SG.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.FW-MGMT-SG.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.FW-MGMT-SG.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group" "FW-DATA-SG" {
  name        = "FW-DATA-Security-Group"
  vpc_id      = alicloud_vpc.fw_vpc.id
  description = "Security Group for FW DATA"
}

resource "alicloud_security_group_rule" "allow_all" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.FW-DATA-SG.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_route_table" "internet-route" {
  description      = "Servers-Route-Table"
  vpc_id           = alicloud_vpc.fw_vpc.id
  route_table_name = "internet-route"
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "default" {
  route_table_id        = alicloud_route_table.internet-route.id
  name                  = "internet-route"
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "HaVip"
  nexthop_id            = alicloud_vpc_ha_vip.trust-havip.id

  depends_on = [
    module.fw1,
    module.fw2,
  ]
}

resource "alicloud_route_table_attachment" "servers-vswitch" {
  vswitch_id     = alicloud_vswitch.Server1-vswitch.id
  route_table_id = alicloud_route_table.internet-route.id
}