#!/bin/bash
sudo cd /opt/tomcat/bin/
sudo sh shutdown.sh
sudo systemctl stop tomcat.service

sudo rm -rf /opt/tomcat/webapps/docs  /opt/tomcat/webapps/examples /opt/tomcat/webapps/host-manager  /opt/tomcat/webapps/manager /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT

sudo chown tomcat:tomcat /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT.war

# cleanup log files
sudo rm -rf /opt/tomcat/logs/catalina*
sudo rm -rf /opt/tomcat/logs/*.log
sudo rm -rf /opt/tomcat/logs/*.txt

#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/tomcat/cloudwatch-config.json -s




