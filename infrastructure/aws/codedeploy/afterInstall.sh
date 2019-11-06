#!/bin/bash


sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/webapps/docs  /opt/tomcat/apache-tomcat-9.0.27/webapps/examples /opt/tomcat/apache-tomcat-9.0.27/webapps/host-manager  /opt/tomcat/apache-tomcat-9.0.27/webapps/manager /opt/tomcat/apache-tomcat-9.0.27/webapps/demo-0.0.1-SNAPSHOT

sudo chown tomcat:tomcat /opt/tomcat/apache-tomcat-9.0.27/webapps/demo-0.0.1-SNAPSHOT.war

# cleanup log files
sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/logs/catalina*
sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/logs/*.log
sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/logs/*.txt

#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/tomcat/cloudwatch-config.json -s




