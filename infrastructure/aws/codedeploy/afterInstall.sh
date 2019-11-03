#!/bin/bash

sudo systemctl stop tomcat

sudo rm -rf /usr/share/tomcat/webapps/demo-0.0.1-SNAPSHOT       

sudo chown tomcat:tomcat /usr/share/tomcat/webapps/demo-0.0.1-SNAPSHOT.war

# cleanup log files
sudo rm -rf /usr/share/tomcat/logs/catalina*
sudo rm -rf /usr/share/tomcat/logs/*.log
sudo rm -rf /usr/share/tomcat/logs/*.txt
