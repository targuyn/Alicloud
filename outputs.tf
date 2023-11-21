output "FW-1-Mgmt" {
  value = module.fw1.fw_mgmt_eip
}

output "FW-2-Mgmt" {
  value = module.fw2.fw_mgmt_eip
}

output "FW-3-Mgmt" {
  value = module.fw3.fw_mgmt_eip
}

output "Web-App" {
  value = "http://${alicloud_eip.havip-eip.ip_address}"
}

output "password_new" {
  value     = var.linux_password
  sensitive = true
}

output "ssh_key_path" {
  value     = var.ssh_key_path
  sensitive = true
}
