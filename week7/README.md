# Setup

You can deploy GoCD server to EKS cluster. Below is the script reference if you are interested to do so.

We are using the following version of the dependency tools
- Helm v3.0.0
- Terraform v0.12.16 + provider.aws v2.40.0
- Saml2aws v2.18.0
- GoCD v19.10.0

Setup GoCD locally through the following link
`https://www.gocd.org/test-drive-gocd.html`

To setup GoCD, we need to do the following setups.

1. Installation of nginx-ingress (Refer to ingress folder)
    ```
    bash ingress/install-ingress.sh
    ```
1. Deploy GoCD on to the EKS cluster (Refer to gocd folder). Remember to create `gocd` namespace.
    ```
    bash gocd/deploy.sh
    ```
1. Creation of LoadBalancer to expose GoCD to the internet (Automation using terraform, do refer to terraform folder for reference).

    ```
    terraform init
    ```
    Before executing the command below, update the value within the file accordingly
    ```
    terraform plan --var-file="terraform.tfvars" -out=terraform.tfplan
    ```
    ```
    terraform apply terraform.plan
    ```

# Pipelines

Note: As we have deployed GoCD server to the cluster, it comes with [GoCD elastic agents](https://docs.gocd.org/current/configuration/elastic_agents.html)

Terraform script in this project is using Route53 domain `*.infrastructure-sandbox.com` on AWS Beach account. 

You can create GOCD pipeline as a code using [YAML](https://github.com/tomzo/gocd-yaml-config-plugin).
Find out more about what it is about [here!](https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html)