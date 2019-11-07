#!/bin/bash

sudo rm -rf /opt/tomcat/webapps/Recipe_Management_System

sudo chown tomcat:tomcat /opt/tomcat/webapps/Recipe_Management_System.war

# cleanup log files
sudo rm -rf /opt/tomcat/logs/catalina*
sudo rm -rf /opt/tomcat/logs/*.log
sudo rm -rf /opt/tomcat/logs/*.txt



