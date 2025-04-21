tf-plan:
	cd terraform && terraform plan -var-file="terraform.tfvars"

tf-init:
	cd terraform && terraform init

tf-apply:
	cd terraform && terraform apply -var-file="terraform.tfvars" -auto-approve -lock=false

tf-destroy:
	cd terraform && terraform destroy -var-file="terraform.tfvars" -auto-approve -lock=false

run-app:
	docker build -t vite-react-app ./web-app
	docker run -d -p 8081:80 web-app
	echo "http://localhost:8081"

run-server:
	docker build -t web-server ./web-server
	docker run -d -p 8080:80 web-server
	echo "http://localhost:8080"

push-app:
	docker build -t web-app ./web-app
	docker tag web-app phulam11031996/web-app
	docker login
	docker push phulam11031996/web-app

push-server:
	docker build -t web-server ./web-server
	docker tag web-server phulam11031996/web-server
	docker login
	docker push phulam11031996/web-server

push-all:
	docker build -t web-app ./web-app
	docker tag web-app phulam11031996/web-app
	docker login
	docker push phulam11031996/web-app
	docker build -t web-server ./web-server
	docker tag web-server phulam11031996/web-server
	docker login
	docker push phulam11031996/web-server

