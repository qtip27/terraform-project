#SECURITY GROUP
locals { # For Multiple Ports for the Security Group
  ports_in = [
    443,
    80,
    22
  ]
  ports_out = [
    443,
    80,
    22
  ]
}

resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id

  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      description = "Access VPC"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = toset(local.ports_out)
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

locals { # For Multiple Ports for the Security Group
  ports_in_1 = [
    22
  ]
  ports_out_1 = [
    22
  ]
}

resource "aws_security_group" "mtc_sg_2" {
  name        = "dev_sg2"
  description = "SSH Only"
  vpc_id      = aws_vpc.mtc_vpc.id

  dynamic "ingress" {
    for_each = toset(local.ports_in_1)
    content {
      description = "SSH to Dev Node"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = toset(local.ports_out)
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}