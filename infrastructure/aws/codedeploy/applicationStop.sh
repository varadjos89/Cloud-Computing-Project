#!/bin/bash

sudo su 

systemctl stop tomcat.service

PID=`ps -eaf | grep "java -jar /opt/tomcat/webapps/ROOT.war" | grep -v grep | awk '{print $2}'`


if [[ "" !=  "$PID" ]]; then
  echo "Found application running on $PID"
  echo "killing the process to stop application"
  echo "killing $PID"
  kill -9 $PID
fi








