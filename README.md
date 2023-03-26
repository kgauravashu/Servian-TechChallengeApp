# Assignment - Servian Tech Challenge

- [Servian tech challenge](https://github.com/servian/TechChallengeApp)
---

### Technical Overview

In this assignment, I chose ECS FARAGATE for deployment of an application and RDS Postgresql 10.17 for the Database 

### AWS Cloud
Amazon Elastic Container Service (ECS)
https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html
Amazon Relational Database Service (RDS)
(https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
Amazon Simple Storage Service (S3)
(https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)

# DevOps Tools
### GitHub and GitHub Actions

Use Github as a Source code management and Github as a pipeline workflow.

### Terraform

Infrastructure as a code tool is used to manage cloud services and due to its declarative syntax, it's a reusable option to create, manage and destroy AWS resources on your fingers.

- [AWS Terraform Modules](https://github.com/terraform-aws-modules)


---



### Tech Dependencies

- [VSCode](https://code.visualstudio.com/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Docker](https://www.docker.com/)
- [Docker-Compose](https://docs.docker.com/compose/)
- Make
- [Terraform 1.4.0](https://www.terraform.io/)


### AWS account authentication

To run below commands, you will need to make sure to be authenticated to an AWS account. That can be done either exporting an AWS IAM User key/secret or by using roles if you have that setup.

[Configure AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

### Manually create an S3 bucket in your AWS account

Create a secure S3 bucket to store the terraform state file

[Create a S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/creating-bucket.html)

### Configure Terraform backend and variables

Before running the Terraform commands, you will need to make sure to configure your backend to point to your own S3 Bucket.

To configure the backend, you will need to edit the file [provider.tf](/terraform/provider.tf) with below:

```
  backend "s3" {
    bucket = "<bucket-name"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
    }
```

### Run Terraform

- `make init`
    This will configure the backend in the provider.tf file and download the cloud provider being used.
- `make plan`
    This will show you which AWS resources will be deployed and save the result in a file called `terraform.plan`.
- `make apply`
    This will apply the `terraform.plan` file with -auto-approve true created in the previous step to deploy resources to your AWS account and create the `terraform.tfstate` file in the manually created S3 bucket.

    After the creation, it will return the outputs [outputs.tf](/terraform/outputs.tf) with the information of the resources created in the cloud.

### Start server and database

(https://github.com/servian/TechChallengeApp/blob/master/doc/readme.md#start-server)

Run 
```
`aws ecs run-task \
    --task-definition <app-name> \
    --cluster <ECS cluster name> \
    --count 1 \
    --launch-type FARGATE \
    --network-configuration '{ "awsvpcConfiguration": {"subnets": [ '<ECS Subnets>' ], "securityGroups": [ '<ECS Security Group' ], "assignPublicIp": "ENABLED"}}' \
    --overrides '{ "containerOverrides": [ { "name": "app", "command": ["updatedb", "-s"] } ] }'
`
```
As Task Definition, ECS Cluster, ECS subnet, ECS Security group and Database instance with database app are already created above using Terraform code and you can check from the output of Terraform run.

### Delete the stack

Once you tested it, it is recommended to delete all resources created on your AWS account to save company bills :D .

For that you just need to run `make destroy`.

---

## GitHub Actions

There is a provided example of a Github Actions Workflow under [/.github/workflows/pipeline.yml](/.github/workflows/pipeline.yml) file.

The workflow example will run if any changes to `/terraform/**` files are commited and below rules are met:

- On pull requests to master
    - make init
    - make plan
- On push to master (merge)
    - make init
    - make plan
    - make apply

