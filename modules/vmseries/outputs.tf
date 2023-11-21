output "fw_mgmt_eip" {
  value = alicloud_instance.vmseries.public_ip
}

output "eni-trust" {
  value = alicloud_network_interface.fw-eni2.id
}

output "eni-untrust" {
  value = alicloud_network_interface.fw-eni1.id
}

output "eni-trust-attach" {
  value = alicloud_network_interface_attachment.fw-trust
}

output "eni-untrust-attach" {
  value = alicloud_network_interface_attachment.fw-untrust
}
