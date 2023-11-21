
resource "null_resource" "update_config" {
  provisioner "local-exec" {
    command     = "python3 ./scripts/fw_config.py"
    working_dir = "./"
  }

  depends_on = [
    module.fw1,
    module.fw2,
    module.fw3,
    alicloud_route_entry.default
  ]
}

resource "null_resource" "disable_dpdk" {
  count = var.disable_dpdk ? 1 : 0
  provisioner "local-exec" {
    command     = "python3 ./scripts/disable_dpdk.py"
    working_dir = "./"
  }
  depends_on = [ null_resource.update_config ]
  
}