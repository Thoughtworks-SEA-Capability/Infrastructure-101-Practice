# Setup

GoCD server is deployed to EKS cluster in AWS

We are using the following version of the dependency tools
- Helm v3.0.0
- Terraform v0.12.16 + provider.aws v2.40.0
- Saml2aws v2.18.0
- GoCD v19.10.0

To setup GoCD, we need to do the following setups
1. Creation of EKS cluster (Refer to eksctl folder)
    ```
    eksctl create cluster -f cluster.yaml --profile <aws-profile-name>
    ```
1. Creation of GoCD namespace (Refer to eksctl folder)
    ```
    kubectl apply -f values.yaml
    ```
1. Installation of nginx-ingress (Refer to ingress folder)
    ```
    bash ingress/install-ingress.sh
    ```
1. Deploy GoCD on to the EKS cluster (Refer to gocd folder)
    ```
    bash gocd/deploy.sh
    ```
1. Creation of LoadBalancer to expose GoCD to the internet (Automation using terrafom, do refer to terraform folder for reference)
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

Head over to this link to get started with pipeline course
https://gocd.infrastructure-sandbox.com/go/pipelines#!/

You can create GOCD pipeline as a code using [YAML](https://github.com/tomzo/gocd-yaml-config-plugin).
Find out more about what it is about [here!](https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html)

# Scenario


1. Create a pipeline of Service A where its task is to print "My Service A Pipeline" on GoCD server.

    **Hint** Refer to the YAML configuration file above to find out more about the syntax
1. Create another service B pipeline which depends on Service A. Create a textfile which contains text such as "Hello from Service B".

    **Hint** Having a pipeline as upstream material and create an artifact
1. Having another independent Service C which will then fan-in to an integration pipeline.
1. Deploying to multiple environment. Fan-out from integration pipeline.Print out the textfile created in step 2.

    **Hint** Try to fetch the artifact