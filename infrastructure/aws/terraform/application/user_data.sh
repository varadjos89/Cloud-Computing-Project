#!/bin/sh
sudo touch /opt/tomcat/webapps/application.yml
sudo chmod 777 /opt/tomcat/webapps/application.yml
sudo echo "amazonProperties:" >> /opt/tomcat/webapps/application.yml
sudo echo "  endpointUrl: ${endpointUrl}" >> /opt/tomcat/webapps/application.yml
sudo echo "  accessKey: ${accessKey}" >> /opt/tomcat/webapps/application.yml
sudo echo "  secretKey: ${secretKey}" >> /opt/tomcat/webapps/application.yml
sudo echo "  bucketName: ${bucketName}" >> /opt/tomcat/webapps/application.yml
