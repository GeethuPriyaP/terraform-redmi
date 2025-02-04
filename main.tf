#---------------KeyPair Creation-----------------#

resource "aws_key_pair" "auth_key" {
  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}

#------------------SecurityGroup-http_access------------#

resource "aws_security_group" "http_access" {
  name        = "${var.project_name}-${var.project_env}-http_access"
  description = "${var.project_name}-${var.project_env}-http_access"

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-http_access"
  }
}

#------------------SecurityGroup-ssh_access------------#

resource "aws_security_group" "ssh_access" {
  name        = "${var.project_name}-${var.project_env}-ssh_access"
  description = "${var.project_name}-${var.project_env}-ssh_access"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-ssh_access"
  }
}

#---------------Ec2 Instance creation-------------#

resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.auth_key.key_name
  user_data              = file("userdata.sh")
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.http_access.id]
  tags = {
    Name = "${var.project_name}-${var.project_env}-frontend"
  }
  lifecycle {
    create_before_destroy = true
  }
}

#-----------------Adding elastic ip---------------#

resource "aws_eip" "frontend" {
  instance = aws_instance.frontend.id
  domain   = "vpc"
  tags = {
    Name = "${var.project_name}-${var.project_env}-frontend"
  }
}

#-----------------Pointing eip in Route53---------#

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "${var.hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 60
  records = [aws_eip.frontend.public_ip]
}
