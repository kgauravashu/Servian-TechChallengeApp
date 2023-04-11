# Assignment - Servian Tech Challenge

- [Servian tech challenge](https://github.com/servian/TechChallengeApp)
---

### Technical Overview

Architecture design:

![image](https://user-images.githubusercontent.com/113504777/231156192-b1dffae3-5009-479e-a4d7-4e67d637e2ef.png)


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
    --network-configuration '{ "awsvpcConfiguration": {"subnets": [ '<ECS Subnets>' ], "securityGroups": [ '<ECS Security Group' ], "assignPublicIp": "ENABLED"}}'
`
```
As Task Definition, ECS Cluster, ECS subnet, ECS Security group and Database instance with database app are already created above using Terraform code and you can check from the output of Terraform run.

### Update database

it'a one time task, Connect the Postgres server and run the command `go run .` inside the checkout repo.
output comes like 

```
$ go run .
go: downloading github.com/spf13/cobra v1.6.1
go: downloading github.com/spf13/viper v1.15.0
go: downloading github.com/lib/pq v1.10.7
go: downloading go.etcd.io/bbolt v1.3.7
go: downloading github.com/GeertJohan/go.rice v1.0.3
go: downloading github.com/gorilla/mux v1.8.0
go: downloading github.com/fsnotify/fsnotify v1.6.0
go: downloading github.com/mitchellh/mapstructure v1.5.0
go: downloading github.com/spf13/afero v1.9.4
go: downloading github.com/spf13/jwalterweatherman v1.1.0
go: downloading github.com/spf13/cast v1.5.0
go: downloading github.com/spf13/pflag v1.0.5
go: downloading github.com/inconshreveable/mousetrap v1.1.0
go: downloading github.com/daaku/go.zipexe v1.0.2
go: downloading golang.org/x/sys v0.5.0
go: downloading github.com/subosito/gotenv v1.4.2
go: downloading github.com/hashicorp/hcl v1.0.0
go: downloading gopkg.in/ini.v1 v1.67.0
go: downloading github.com/magiconair/properties v1.8.7
go: downloading github.com/pelletier/go-toml/v2 v2.0.6
go: downloading gopkg.in/yaml.v3 v3.0.1
go: downloading golang.org/x/text v0.7.0

 .:ooooool,      .:odddddl;.      .;ooooc. .l,          ;c.    ::.      'coddddoc'         ,looooooc.
'kk;....';,    .lOx:'...,cxkc.   .dOc....  .xO'        ,0d.   .kk.    ,xko;....;okx,     .xkl,....;dOl.
:Xl           .xO,         :0d.  ;Kl        ,0o       .dO'    .kk.   :0d.        .d0:   .xO'        lK:
.oOxc,.       lKl...........oK:  :Kc         l0;      :Kc     .kk.  .Ok.          .kO.  '0d         '0d
  .;ldddo;.   oXkdddddddddddxx,  :Kc         .kk.    .Ox.     .kk.  '0d            d0'  '0d         '0d
       .cOk.  lKc                :Kc          :0l    o0;      .kk.  .Ok.          .k0'  '0d         '0d
         cXc  .xO;         ..    :Kc          .d0'  ;0o       .kk.   :0d.        .dN0'  '0d         '0d
,c,....'cOx.   .lOxc,...':dkc.   :Kc           'Ox',kk.       .kk.    ,xko;'..';okk00,  '0d         '0d   ';;;;;;;;;;,.
'looooool;.      .;ldddddo:.     'l'            .lool.         ::       'coddddoc'.;l.  .l;         .c;  .cxxxxxxxxxxo.

This application is used as part of challenging potential candiates at Sevian.

Please visit http://Servian.com for more details

Usage:
  TechChallengeApp [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  help        Help about any command
  serve       Starts the web server
  updatedb    Updates DB

Flags:
  -h, --help      help for TechChallengeApp
  -v, --version   version for TechChallengeApp

Use "TechChallengeApp [command] --help" for more information about a command.
```

Then run the command:

```
$ go build -o TechChallengeApp
$ ./TechChallengeApp updatedb
Dropping and recreating database: app
DROP DATABASE IF EXISTS app
CREATE DATABASE app
WITH
OWNER = postgres
ENCODING = 'UTF8'
LC_COLLATE = 'en_US.utf8'
LC_CTYPE = 'en_US.utf8'
TABLESPACE = pg_default
CONNECTION LIMIT = -1
TEMPLATE template0;
Dropping and recreating table: tasks
DROP TABLE IF EXISTS tasks CASCADE
CREATE TABLE tasks ( id SERIAL PRIMARY KEY, completed boolean NOT NULL, priority integer NOT NULL, title text NOT NULL)
Seeding table with data
Dropping and recreating database: app
Dropping and recreating table: tasks
Seeding table with data
```


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

