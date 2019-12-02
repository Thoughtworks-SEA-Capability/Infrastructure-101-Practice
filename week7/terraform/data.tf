#################################################################
# DATAS
#################################################################

data "aws_eks_cluster" "my_cluster" {
  name = var.cluster-name
}

data "aws_subnet_ids" "public_subnet" {
  vpc_id = local.vpc-id

  filter {
    name = "tag:kubernetes.io/role/elb"
    values = [
      "1"]
  }
}

data "aws_subnet" "public_subnet" {
  count = length(data.aws_subnet_ids.public_subnet.ids)
  id = tolist(data.aws_subnet_ids.public_subnet.ids)[count.index]
}

data "aws_autoscaling_groups" "groups" {
  filter {
    name = "key"
    values = [
      "alpha.eksctl.io/cluster-name"]
  }

  filter {
    name = "value"
    values = [
      var.cluster-name]
  }
}

data "aws_acm_certificate" "domain-arn" {
  domain = "*.${var.ingress_domain}"
  statuses = [
    "ISSUED"]
}

data "aws_route53_zone" "zone-id" {
  name = "${var.ingress_domain}."
}
