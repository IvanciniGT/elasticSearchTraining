docker rm myfilebeat -f && echo deleted || echo not found

docker container create \
    -v /home/ubuntu/environment/data/apache:/logs \
    -v $PWD/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro \
    --name myfilebeat \
    elastic/filebeat:8.5.0
    
docker container start myfilebeat
