#!/bin/bash


sudo rm -rf /opt/tomcat/webapps/docs  /opt/tomcat/webapps/examples /opt/tomcat/webapps/host-manager  /opt/tomcat/webapps/manager /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT

sudo chown tomcat:tomcat /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT.war

# cleanup log files
sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/logs/catalina*
sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/logs/*.log
sudo rm -rf /opt/tomcat/apache-tomcat-9.0.27/logs/*.txt

#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/tomcat/cloudwatch-config.json -s




