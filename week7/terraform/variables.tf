#################################################################
# VARIABLES
#################################################################

variable "ingress_domain" {}

variable "saml_profile" {
  default = "saml"
  type    = string
}

variable "region" {
  default = "ap-southeast-1"
  type    = string
}

variable "security_group_id" {}

variable "cluster-name" {
  default = "eks-cluster"
  type    = string
}
