# --- modules/lambda/main.tf ---

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "wating-room-auth-tokens-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "wating-room-auth-tokens-vpc-terraform"
  }
}

resource "aws_subnet" "wating-room-auth-tokens-subnet" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.wating-room-auth-tokens-vpc.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.wating-room-auth-tokens-vpc.id]
  }
}
