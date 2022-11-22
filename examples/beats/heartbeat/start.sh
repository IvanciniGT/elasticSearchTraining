docker rm myheartbeat -f && echo deleted || echo not found

docker container create \
    -v $PWD/apache.heartbeat.yaml:/usr/share/heartbeat/heartbeat.yml:ro \
    --name myheartbeat \
    elastic/heartbeat:8.5.0
    
docker container start myheartbeat
