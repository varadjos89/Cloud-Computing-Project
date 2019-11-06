#!/bin/bash

# stop tomcat service
sudo systemctl stop tomcat.service

#echo "getting the process id"
#PID=`ps -eaf | grep "java -jar /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT.war" | grep -v grep | awk '{print $2}'`
#echo "process id not empty ? $PID"
#if [[ "" !=  "$PID" ]]; then
#  echo "Found application running on $PID"
#  echo "killing the process to stop application"
#  echo "killing $PID"
#  kill -9 $PID
#fi

