docker rm myapache -f && echo deleted || echo not found

docker container create \
    -p 8082:80 \
    -v /home/ubuntu/environment/data/apache:/logs \
    -v $PWD/httpd.conf:/usr/local/apache2/conf/httpd.conf \
    --name myapache \
    httpd:latest

docker container start myapache