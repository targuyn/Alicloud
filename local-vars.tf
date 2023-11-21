locals {
  # # VM-Series User Data - check this URL for other supported parameters
  # # https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-alibaba-cloud/deploy-the-vm-series-firewall-on-alibaba-cloud/create-and-configure-the-vm-series-firewall.html#id0ba23c65-f58b-4922-92cb-6e75e8eacf30


  fw1_user_data = <<EOF
type=dhcp-client
hostname=${var.instance1-name}
dhcp-send-hostname=yes
dhcp-send-client-id=yes
dhcp-accept-server-hostname=yes
dhcp-accept-server-domain=yes
authcodes=${var.auth_code}
EOF

  fw2_user_data = <<EOF
type=dhcp-client
hostname=${var.instance2-name}
dhcp-send-hostname=yes
dhcp-send-client-id=yes
dhcp-accept-server-hostname=yes
dhcp-accept-server-domain=yes
authcodes=${var.auth_code}
EOF

  fw3_user_data = <<EOF
type=dhcp-client
hostname=${var.instance3-name}
dhcp-send-hostname=yes
dhcp-send-client-id=yes
dhcp-accept-server-hostname=yes
dhcp-accept-server-domain=yes
authcodes=${var.auth_code}
EOF

}
