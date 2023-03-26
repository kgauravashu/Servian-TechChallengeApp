init:
	docker-compose run terraform init

validate:
	docker-compose run terraform validate

plan:
	docker-compose run terraform plan -out terraform.plan

apply:
	docker-compose run terraform apply terraform.plan

destroy:
	docker-compose run terraform destroy
