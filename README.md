# CSYE 6225 - Fall 2019

## Team Information

| Name | NEU ID | Email Address |
| Varad Joshi| 001492002 |joshi.vara@husky.neu.edu |

## Technology Stack

Java
Spring Boot
MySQL
Hibernate

## Build Instructions

1) Clone the repository using SSH key
2) Open the project: Recipe_Management_System in webapps folder using IntelliJ or any IDE
3) IntelliJ will ask to import maven dependencies
4) After import is successful build and run the project

## Deploy Instructions

1) Install Postman and create a collection
2) Create three requests: Get, Post, Put as specified by assignment guidelines
3) For Get enter url: /v1/user/self and then in authorization tab select basic auth and enter user credentials to log in
4) For Post enter url: /v1/user and then enter user information in JSON format in body tab
5) For Update enter url: /v1/user/self and then enter user information in JSON format in body tab and select basic auth in authorization tab after entering user credentials 

## Running Tests

Check for HTTP status code in postman for each request

## CI/CD

1)Create IAM roles and plocies using terraform.
2)Login to circleci and configure it for your github account.
3)Add environment variables for circleci.
4)Configure circleci to track certain branch on github.
5)Create circleci user and attach respective policies to it.
6)Commit your changes to github and the changes will be deployed automatically on EC2 instance. 


