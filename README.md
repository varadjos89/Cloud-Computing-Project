# CSYE 6225 - Fall 2019

## Technology Stack

Java <br/>
Spring Boot <br/>
MySQL <br/>
Hibernate <br/>

## Build Instructions

1) Clone the repository using SSH key
2) Open the project: Recipe_Management_System in webapps folder using IntelliJ or any IDE
3) IntelliJ will ask to import maven dependencies
4) After import is successful build and run the project

## Steps to provision AWS Infrastructure

1) Go to /infrastructure/aws/terraform/application/module1/ directory.
2) Create terraform.tfvars file and initialize all the resources in it.
3) Important fields include checking vpc_id, domain_name, key_name, account_id, am_id etc.
4) Install AWS CLI in your system.
5) Configure AWS credential file by running "aws configure" command.
6) Go to AWS console, visit Route53 and create a hosted zone with your domain name. [prod.varadjoshi89.xyz ]
7) Enter all your NS record values from AWS console to your Domain provider's NameServer.
8) Go to ACM, request HTTPS certificate with same domain name and create a CNAME record for it inside your hosted zone.(option will pop-up once you create certificate).
9) Run "terraform init" to initialize working directory, "terraform plan" to create execution plan and lastly "terraform apply" to provision resources into AWS cloud.

## ScreenShots
![Screenshot from 2020-10-26 21-06-58](https://user-images.githubusercontent.com/48415852/97244944-51539280-17d0-11eb-9842-7cbd5911e81f.png)
![Screenshot from 2020-10-26 21-07-30](https://user-images.githubusercontent.com/48415852/97244948-531d5600-17d0-11eb-9f14-924e17dd889c.png)
![Screenshot from 2020-10-26 21-07-41](https://user-images.githubusercontent.com/48415852/97244951-557fb000-17d0-11eb-88de-4fde29ce74b6.png)
![Screenshot from 2020-10-26 21-08-36](https://user-images.githubusercontent.com/48415852/97244958-59133700-17d0-11eb-9d12-e01696f5b86f.png)
![Screenshot from 2020-10-26 21-09-36](https://user-images.githubusercontent.com/48415852/97244961-5adcfa80-17d0-11eb-9132-c33ca8eaffb0.png)
![Screenshot from 2020-10-26 21-10-49](https://user-images.githubusercontent.com/48415852/97244972-603a4500-17d0-11eb-8027-5ef18bd7b31a.png)
![Screenshot from 2020-10-26 21-11-01](https://user-images.githubusercontent.com/48415852/97244981-63cdcc00-17d0-11eb-8060-28b50c3b5ffb.png)
![Screenshot from 2020-10-26 21-11-17](https://user-images.githubusercontent.com/48415852/97244983-65978f80-17d0-11eb-9747-93edf24f830c.png)
![Screenshot from 2020-10-26 21-11-26](https://user-images.githubusercontent.com/48415852/97244988-67f9e980-17d0-11eb-8c42-6eddd2b7717e.png)
![Screenshot from 2020-10-26 21-12-06](https://user-images.githubusercontent.com/48415852/97244990-6a5c4380-17d0-11eb-918d-96bdc88972a8.png)
![Screenshot from 2020-10-26 21-12-49](https://user-images.githubusercontent.com/48415852/97244995-6cbe9d80-17d0-11eb-9758-d38180d17fb7.png)

## Steps for CI/CD Pipeline

1) Refer Readme file for fa19-team-025-ami to configure CircleCI with Github.
2) CircleCI file(config.yml) within the repository has been configured with all the commands require to build, test, deploy the artifact to S3 bucket and make
   CodeDeploy API call.
3) CodeDeploy will pick the latest build file from S3 bucket and deploy it onto load balanced group of EC2 instances.
4) I used Postman here to test all the APIs.

## ScreenShots
![Screenshot from 2020-10-26 23-22-07](https://user-images.githubusercontent.com/48415852/97254140-22dfb280-17e4-11eb-997b-36841222a22e.png)
![Screenshot from 2020-10-26 23-22-16](https://user-images.githubusercontent.com/48415852/97254145-24a97600-17e4-11eb-9644-10cca0f5281a.png)
![Screenshot from 2020-10-26 23-22-18](https://user-images.githubusercontent.com/48415852/97254147-26733980-17e4-11eb-9806-b74440e82cb3.png)
![Screenshot from 2020-10-26 23-22-29](https://user-images.githubusercontent.com/48415852/97254154-27a46680-17e4-11eb-9d4b-43e8ead9cf1f.png)
![Screenshot from 2020-10-26 23-22-45](https://user-images.githubusercontent.com/48415852/97254162-2b37ed80-17e4-11eb-8ed7-ed52dfc6c08e.png)
![Screenshot from 2020-10-26 23-23-04](https://user-images.githubusercontent.com/48415852/97254166-2d9a4780-17e4-11eb-88f6-c479b597aaac.png)
![Screenshot from 2020-10-26 23-23-11](https://user-images.githubusercontent.com/48415852/97254176-30953800-17e4-11eb-900f-3415d4c2cd5b.png)
![Screenshot from 2020-10-26 23-32-47](https://user-images.githubusercontent.com/48415852/97254184-32f79200-17e4-11eb-9bd4-c346eebf5765.png)
![Screenshot from 2020-10-26 23-32-50](https://user-images.githubusercontent.com/48415852/97254195-368b1900-17e4-11eb-9331-21a8fc1a026c.png)




