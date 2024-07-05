# --- modules/security_group/main.tf ---

resource "aws_security_group" "lambda_sg" {
    name        = "lambda-sg"
    description = "Security group for Lambda"

    vpc_id = var.vpc_id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        self = true
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "redis_sg" {
    name        = "redis-sg"
    description = "Security group for Redis"

    vpc_id = var.vpc_id

    ingress {
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        security_groups = [aws_security_group.lambda_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
