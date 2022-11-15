docker run \
    --name mylogstash \
    -it \
    --rm \
    -p 5044:5044 \
    -v /home/ubuntu/environment/training/examples/logstash/data:/data \
    -v /home/ubuntu/environment/training/examples/logstash/templates:/templates \
    -v /home/ubuntu/environment/training/examples/logstash/pipelines/$1:/usr/share/logstash/pipeline/logstash.conf \
    docker.elastic.co/logstash/logstash:7.9.2
    