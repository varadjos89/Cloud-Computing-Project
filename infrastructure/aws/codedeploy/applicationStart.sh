#!/bin/bash

#sudo cd /opt/tomcat/bin/
#sudo sh startup.sh
#sudo systemctl start tomcat.service
#java -jar /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT.war &

nohup java -jar /opt/tomcat/webapps/demo-0.0.1-SNAPSHOT.war > /path/to/log.txt 2>&1 &
echo $! > /path/to/app/pid.file


