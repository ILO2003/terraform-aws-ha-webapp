#Getting already exsiting prefix list to use CloudFront IPs only
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}
resource "aws_security_group" "ALB-SG" {
  name        = "Allow-HTTP-SG"
  description = "Allows inbound traffic from CloudFront ONLY on port 80"
  vpc_id      = aws_vpc.webapp-vpc.id

  tags = {
    Name = "ALB-sec-group"
  }
}
#Internal facing ALB -> no longer internetfacing from last project.
resource "aws_vpc_security_group_ingress_rule" "ALB-SG-INGRESS" {
  security_group_id = aws_security_group.ALB-SG.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "ALB-SG-EGRESS" {
  security_group_id            = aws_security_group.ALB-SG.id
  referenced_security_group_id = aws_security_group.APP-SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_security_group" "APP-SG" {
  name        = "Allow ALB-SG to APP"
  description = "Allows traffic from ALB to APP sg on port 80"
  vpc_id      = aws_vpc.webapp-vpc.id

  tags = {
    Name = "APP-sec-group"
  }

}
resource "aws_vpc_security_group_ingress_rule" "APP-SG-INGRESS" {
  security_group_id            = aws_security_group.APP-SG.id
  referenced_security_group_id = aws_security_group.ALB-SG.id

  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
resource "aws_vpc_security_group_egress_rule" "APP-SG-EGRESS" {
  security_group_id            = aws_security_group.APP-SG.id
  referenced_security_group_id = aws_security_group.DB-SG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_security_group" "DB-SG" {
  name        = "Allow APP-SG to DB"
  description = "Allows traffic from APP to DB sg on port 3306"
  vpc_id      = aws_vpc.webapp-vpc.id

  tags = {
    Name = "DB-sec-group"
  }

}
resource "aws_vpc_security_group_ingress_rule" "DB-SG-INGRESS" {
  security_group_id            = aws_security_group.DB-SG.id
  referenced_security_group_id = aws_security_group.APP-SG.id

  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}