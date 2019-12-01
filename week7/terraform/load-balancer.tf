locals {
  vpc-id = "${data.aws_eks_cluster.my_cluster.vpc_config.0.vpc_id}"
}

resource "aws_lb_target_group" "devsecops-ingress-target-group" {
  name        = "devsecops-ingress-target-group"
  port        = 30950
  protocol    = "HTTPS"
  vpc_id      = "${local.vpc-id}"
  target_type = "instance"

  tags {
    Name = "devsecops_ingress_target_group"
  }
}

resource "aws_lb" "devsecops-ingress-alb" {
  name               = "devsecops-ingress-alb"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.devsecops-ingress-sg.id}"]
  subnets            = ["${data.aws_subnet.public_subnet.*.id}"]

  tags = "${
    map(
     "Name", "devsecops-ingress-alb",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group" "devsecops-ingress-sg" {
  name        = "devops-ingress-security-group"
  vpc_id      = "${local.vpc-id}"
  description = "Security group for K8S ALBs"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow-connection-to-ingress" {
  description       = "Allow node to expose its connection to public"
  from_port         = 30950
  to_port           = 30950
  protocol          = "tcp"
  security_group_id = "${var.security_group_id}"
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}

resource "aws_security_group_rule" "allow_all_https" {
  type              = "ingress"
  security_group_id = "${aws_security_group.devsecops-ingress-sg.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.devsecops-ingress-sg.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb_listener" "devsecops-ingress-listener" {
  load_balancer_arn = "${aws_lb.devsecops-ingress-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.domain-arn.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.devsecops-ingress-target-group.arn}"
  }
}

resource "aws_autoscaling_attachment" "devsecops-ingress-attachment-1" {
  autoscaling_group_name = "${data.aws_autoscaling_groups.groups.names[0]}"
  alb_target_group_arn   = "${aws_lb_target_group.devsecops-ingress-target-group.arn}"
}

resource "aws_route53_record" "devsecops-gocd-domain" {
  name = "gocd.${var.ingress_domain}"
  type = "A"

  alias = {
    name                   = "${aws_lb.devsecops-ingress-alb.dns_name}"
    zone_id                = "${aws_lb.devsecops-ingress-alb.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "${data.aws_route53_zone.zone-id.zone_id}"
}

output "subnet_cidr_blocks" {
  value = "${data.aws_subnet.public_subnet.*.cidr_block}"
}
