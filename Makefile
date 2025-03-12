tf-apply:
	terraform apply -var-file="main.tfvars" -auto-approve -lock=false

tf-destroy:
	terraform destroy -var-file="main.tfvars" -auto-approve -lock=false

