docker rm myfilebeat -f && echo deleted || echo not found

docker container create \
    -v $PWD:/data \
    -v $PWD/cities.yml:/usr/share/filebeat/filebeat.yml:ro \
    --name myfilebeat \
    elastic/filebeat:8.5.0
    
docker container start myfilebeat
