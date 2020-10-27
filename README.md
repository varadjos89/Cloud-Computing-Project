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



## Deploy Instructions

1) Install Postman and create a collection
2) Create three requests: Get, Post, Put as specified by assignment guidelines
3) For Get enter url: /v1/user/self and then in authorization tab select basic auth and enter user credentials to log in
4) For Post enter url: /v1/user and then enter user information in JSON format in body tab
5) For Update enter url: /v1/user/self and then enter user information in JSON format in body tab and select basic auth in authorization tab after entering user credentials 


