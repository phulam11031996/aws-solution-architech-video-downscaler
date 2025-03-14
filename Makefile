tf-plan:
	cd terraform && terraform plan -var-file="terraform.tfvars"

tf-init:
	cd terraform && terraform init

tf-apply:
	cd terraform && terraform apply -var-file="terraform.tfvars" -auto-approve -lock=false

tf-destroy:
	cd terraform && terraform destroy -var-file="terraform.tfvars" -auto-approve -lock=false

push-web-app-to-docker-hub:
	docker build -t web-app ./web-app
	docker tag web-app phulam11031996/web-app
	docker login
	docker push phulam11031996/web-app

tf-apply-vpc:
	cd terraform && terraform apply -var-file="terraform.tfvars" -auto-approve -lock=false
