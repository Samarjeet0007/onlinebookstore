FROM tomcat:8
MAINTAINER "samarjeetkumar962@gmail.com"
COPY target/*.war /usr/local/tomcat/webapps/onlinebookstore.war
