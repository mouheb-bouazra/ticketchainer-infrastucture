# --- modules/redis/variables.tf ---

variable "vpc_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "vpc_subnet_ids" {
  type = list(string)
}