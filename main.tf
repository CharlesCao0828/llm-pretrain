variable "region" {
  description = "阿里云地域"
  default     = "cn-beijing"
}

variable "zone_id" {
  description = "可用区 ID"
  default     = "cn-beijing-g"
}

variable "allow_ssh_cidr" {
  description = "允许通过 SSH 远程登录实例的 IP 段"
  default     = "" # 请记得将其更改为您特定的公网 IP
}

variable "instance_type" {
  description = "ECS 实例的规格类型"
  default     = "ecs.e-c1m1.large"
}

variable "image_id" {
  description = "操作系统镜像 ID"
  default     = "ubuntu_24_04_x64_20G_alibase_20251126.vhd"
}
