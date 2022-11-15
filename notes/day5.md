FileBeat 
Logstash

FIRST CONFIGURATION 

Apache
    access.log -> file 
Filebeat
    access.log entries -> ES

SECOND CONFIGURATION 

Apache
    access.log -> file                              √
Filebeat
    access.log entries -> Logstash
Logstash 
    Each entry -> ES


# Beats family

Are a number of programs that read information from different sources and send that information away !

## Filebeat: Read infromation from FILES

## Metricbeat: read information from METRICS? Process metrics or HARDWARE metrics

## Packetbeat: read infroamtion from the packages being send or received thru a network

## Winlogbeat: Read information from the Windows logs

## Auditbeat: Read infromation from Linux/Unix logs

## Heartbeat: read information from services (to check whether they are working or not)

## Functionbeat: For cloud information

## Install apache: 
docker container create \
    -p 8082:80 \
    -v /home/ubuntu/environment/data/apache:/logs \
    --name myapache \
    httpd:latest