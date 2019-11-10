#!/bin/bash

nohup java -jar /opt/tomcat/webapps/ROOT.war > /opt/tomcat/webapps/log.txt 2>&1 &



