terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.200"
    }
  }
}

# 阿里云 Provider 配置
provider "alicloud" {
  region = var.region
}

# 1. 专有网络 (VPC)
resource "alicloud_vpc" "main_vpc" {
  vpc_name   = "llm-pretrain-vpc"
  cidr_block = "172.16.0.0/12"
}

# 2. 交换机 (VSwitch)
resource "alicloud_vswitch" "main_vswitch" {
  vswitch_name = "lm-pretrain-vswitch"
  vpc_id        = alicloud_vpc.main_vpc.id
  cidr_block    = "172.16.1.0/24"
  zone_id       = var.zone_id
}

# 3. 安全组 (Security Group)
resource "alicloud_security_group" "web_ssh_group" {
  security_group_name   = "allow-web-and-ssh"
  vpc_id                = alicloud_vpc.main_vpc.id
}

# 4. 安全组规则 - 允许 SSH (22端口)
# 仅限 var.allow_ssh_cidr 定义的特定 IP 访问
resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.web_ssh_group.id
  cidr_ip           = var.allow_ssh_cidr
}

# 5. 安全组规则 - 允许 HTTP (80端口)
# 通常 Web 服务允许全网访问 (0.0.0.0/0)
resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.web_ssh_group.id
  cidr_ip           = "0.0.0.0/0" 
}

# 6. ECS 实例配置
resource "alicloud_instance" "llm-pretrain-server" {
  availability_zone = var.zone_id
  security_groups   = [alicloud_security_group.web_ssh_group.id]
  vswitch_id        = alicloud_vswitch.main_vswitch.id
  
  instance_type        = var.instance_type
  image_id             = var.image_id
  instance_charge_type = "PostPaid"           # 按量付费
  system_disk_category = "cloud_essd"         # 高性能 ESSD 云盘
  instance_name        = "terraform-ecs-instance"
  
  password                   = "YourPassword123!" 
  internet_max_bandwidth_out = 5              # 公网出带宽 5Mbps
}
