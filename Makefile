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

push-web-server-to-docker-hub:
	docker build -t web-server ./web-server
	docker tag web-server phulam11031996/web-server
	docker login
	docker push phulam11031996/web-server

tf-apply-vpc:
	cd terraform && terraform apply -var-file="terraform.tfvars" -auto-approve -lock=false

check-ip:
	curl ifconfig.me

run-web-app:
	docker build --build-arg VITE_API_URL=https://api.example.com -t vite-react-app ./web-app
	docker run -d -p 8080:80 -e VITE_API_URL=https://your-api.com vite-react-app

