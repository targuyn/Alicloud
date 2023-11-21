resource "alicloud_fc_service" "paloalto-failover-service" {
  depends_on      = [alicloud_ram_role.faas_ram_role]
  name            = "havip-failover-${alicloud_vpc.fw_vpc.name}"
  description     = "Failover between one zone with HAVIP and another zone with ENI"
  internet_access = true
  vpc_config {
    vswitch_ids       = [alicloud_vswitch.zone1-vswitch-trust.id]
    security_group_id = alicloud_security_group.FW-DATA-SG.id
  }
  role = alicloud_ram_role.faas_ram_role.arn
}

resource "alicloud_fc_function" "active-standby" {
  service     = alicloud_fc_service.paloalto-failover-service.name
  name        = "paloalto-failover-service-${alicloud_vpc.fw_vpc.name}"
  description = "Palo Alto Active Standby - AliCloud Created by Terraform"
  filename    = "./func/faas.zip"
  memory_size = "128"
  runtime     = "python3"
  handler     = "faas.handler"
  timeout     = "60"
  environment_variables = {
    ACCESS_KEY        = "${var.access_key}"
    ACCESS_SECRET     = "${var.secret_key}"
    REGION_ID         = "${var.region}"
    EIP_ADDRESS       = "${alicloud_eip.havip-eip.ip_address}"
    EIP_ID            = "${alicloud_eip.havip-eip.id}",
    INSTANCE_ID_ENI   = "${module.fw3.eni-untrust}",
    INSTANCE_ID_HAVIP = "${alicloud_vpc_ha_vip.untrust-havip.id}",
    NEXT_HOP_ID_ENI   = "${module.fw3.eni-trust}",
    NEXT_HOP_ID_HAVIP = "${alicloud_vpc_ha_vip.trust-havip.id}",
    ROUTE_TABLE_ID    = "${alicloud_route_table.internet-route.id}",
    URL               = "http://${alicloud_vpc_ha_vip.trust-havip.ip_address}"
  }
}

//Function Compute Trigger
resource "alicloud_fc_trigger" "timer" {
  service  = alicloud_fc_service.paloalto-failover-service.name
  function = alicloud_fc_function.active-standby.name
  name     = "CronTrigger"
  type     = "timer"
  config   = <<EOF
{

            "cronExpression": "@every 5m",
            "enable": true
        }

EOF

}

resource "alicloud_ram_role" "faas_ram_role" {
  name        = "FunctionCompute-RAM-Role-${alicloud_vpc.fw_vpc.name}"
  document    = <<EOF
{
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
        "Service": [
            "fc.aliyuncs.com"
        ]
    }
    }
],
"Version": "1"
}
EOF
  description = "FunctionCompute-RAM-Role"
  force       = true
}


resource "alicloud_ram_policy" "faas_policy" {
  policy_name     = "faas-RAM-Policy-${alicloud_vpc.fw_vpc.name}"
  policy_document = <<EOF
{
"Statement": [

    {
    "Action": "ecs:*", 
    "Resource": "*", 
    "Effect": "Allow"
    }, 
    {
    "Action": [
    "vpc:DescribeVpcs", 
    "vpc:DescribeVSwitches"
    ], 
    "Resource": "*", 
    "Effect": "Allow"
    },

    {
    "Action": [
        "vpc:*HaVip*", 
        "vpc:*RouteTable*", 
        "vpc:*VRouter*", 
        "vpc:*RouteEntry*", 
        "vpc:*VSwitch*", 
        "vpc:*Vpc*", 
        "vpc:*Cen*", 
        "vpc:*Tag*", 
        "vpc:*NetworkAcl*"
    ], 
    "Resource": "*", 
    "Effect": "Allow"
    },

    {
    "Action": [
        "vpc:*Eip*", 
        "vpc:*HighDefinitionMonitor*"
    ], 
    "Resource": "*", 
    "Effect": "Allow"
    }, 
    {
    "Action": "ecs:DescribeInstances", 
    "Resource": "*", 
    "Effect": "Allow"
    },

    {
    "Action": [
        "vpc:DescribeVSwitchAttributes"
    ], 
    "Resource": "*", 
    "Effect": "Allow"
    }, 
    {
    "Action": [
        "ecs:CreateNetworkInterface", 
        "ecs:DeleteNetworkInterface", 
        "ecs:DescribeNetworkInterfaces", 
        "ecs:CreateNetworkInterfacePermission", 
        "ecs:DescribeNetworkInterfacePermissions", 
        "ecs:DeleteNetworkInterfacePermission"
    ], 
    "Resource": "*", 
    "Effect": "Allow"
    }
],

"Version": "1"
}
EOF
  description     = "FunctionCompute-RAM-Role"
  force           = true
}

resource "alicloud_ram_role_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.faas_policy.name
  policy_type = alicloud_ram_policy.faas_policy.type
  role_name   = alicloud_ram_role.faas_ram_role.name
}

resource "alicloud_ram_role_policy_attachment" "logs" {
  role_name   = alicloud_ram_role.faas_ram_role.name
  policy_type = "System"
  policy_name = "AliyunLogFullAccess"
}