docker run \
    --name mylogstash \
    -it \
    -p 5044:5044 \
    -p 5045:5045 \
    -p 5046:5046 \
    -v /home/ubuntu/environment/training/examples/logstash/data:/data \
    -v /home/ubuntu/environment/training/examples/logstash/templates:/templates \
    -v /home/ubuntu/environment/training/examples/logstash/pipelines/$1:/usr/share/logstash/pipeline/logstash.conf \
    docker.elastic.co/logstash/logstash:7.9.2
    