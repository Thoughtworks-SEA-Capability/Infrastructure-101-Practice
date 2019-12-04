init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan --var-file="terraform.tfvars" -out=terraform.tfplan

apply:
	cd terraform && terraform apply terraform.tfplan

