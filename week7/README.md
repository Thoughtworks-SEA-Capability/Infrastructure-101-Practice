# Setup

GoCD server is deployed to EKS cluster in AWS

We are using the following version of the dependency tools
- Helm v3.0.0
- Terraform v0.11.13 + provider.aws v2.40.0
- Saml2aws v2.18.0
- GoCD v19.10.0

To setup GoCD, we need to do the following setups
1. Creation of EKS cluster (Refer to eksctl folder)
1. Creation of GoCD namespace (Refer to eksctl folder)
1. Installation of nginx-ingress (Refer to ingress folder)
1. Deploy GoCD on to the EKS cluster (Refer to gocd)
1. Creation of LoadBalancer to expose GoCD to the internet (Automation using terrafom, do refer to terraform folder for reference)

# Pipelines

Note: As we have deployed GoCD server to the cluster, it comes with [GoCD elastic agents](https://docs.gocd.org/current/configuration/elastic_agents.html)

Head over to this link to get started with pipeline course
https://gocd.infrastructure-sandbox.com/go/pipelines#!/

You can create GOCD pipeline as a code using [YAML](https://github.com/tomzo/gocd-yaml-config-plugin).
Find out more about what it is about [here!](https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html)