# --- root/variables.tf ---

variable "region" {}
variable "profile" {}
variable "cidr_block" {}
variable "subnet_cidr_blocks" {}
variable "jwt_public_key" {
    description = "value of the public key to validate JWT tokens"
    default = "-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEAy9CcY5dy/H2WTnkD0n4RL8lSsDxtzpPBM37tg60V22SSXUsvjY4y\nW5UHYdgtjfNMGP0py9VozT7ouafQWLxuZqD+0Lx6yWzAbKBUTkN1rdv8MqNNnjAp\nYEhsMUCBHkrrf59chwkgivcMlC7Y9iwkmBh9dkMz/UB0ru6c6gPBroCbw5M0whcR\nhbIHzYW0UBYtjyYQ+ekiPkm4bPbcrNo+HJy9jXqxEjj+b7O3T2OX6ClM5wAtySzf\nZnJHDJS/RTzvT4LagnpGBcmsbTfM/AqtvgpQV2Zz5eDUsp6vFGPJpfX9GF/g7riY\n8prmPqDctiC/JU6zp6pwGifRLyjXZYimrwIDAQAB\n-----END RSA PUBLIC KEY-----\n"
}
