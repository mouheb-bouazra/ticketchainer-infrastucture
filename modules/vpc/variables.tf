# --- modules/lambda/variables.tf ---
variable "cidr_block" {
  type = string  
}

variable "subnet_cidr_blocks" {
  type = list(string)  
}