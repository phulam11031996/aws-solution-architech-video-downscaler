tf-init:
	cd terraform && terraform init

tf-apply:
	cd terraform && terraform apply -var-file="main.tfvars" -auto-approve -lock=false

tf-destroy:
	cd terraform && terraform destroy -var-file="main.tfvars" -auto-approve -lock=false

push-web-app-to-docker-hub:
	docker build -t web-app ./web-app
	docker tag web-app phulam11031996/web-app
	docker login
	docker push phulam11031996/web-app
