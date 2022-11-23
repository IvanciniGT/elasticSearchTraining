export IP="172.31.3.117"

sed -e "s/\${IP}/$IP/g" apache/heartbeat/heartbeat.template.yml > apache/heartbeat/heartbeat.yml
sed -e "s/\${IP}/$IP/g" apache/filebeat/filebeat.template.yml > apache/filebeat/filebeat.yml
sudo rm apache/metricbeat/metricbeat.yml 
sed -e "s/\${IP}/$IP/g" apache/metricbeat/metricbeat.template.yml >  apache/metricbeat/metricbeat.yml
sudo chmod 644  apache/heartbeat/heartbeat.yml
sudo chmod 644  apache/filebeat/filebeat.yml
sudo chmod 644  apache/metricbeat/metricbeat.yml
sudo chown root:root  apache/metricbeat/metricbeat.yml
sed -e "s/\${IP}/$IP/g" apache/docker-compose.template.yaml > apache/docker-compose.yml
sed -e "s/\${IP}/$IP/g" elastic-kibana/instances.template.yml > elastic-kibana/instances.yml
sed -e "s/\${IP}/$IP/g" logstash/pipelines/pipeline_heartbeat.template.conf > logstash/pipelines/pipeline_heartbeat.conf
sed -e "s/\${IP}/$IP/g" logstash/pipelines/pipeline_filebeat.template.conf > logstash/pipelines/pipeline_filebeat.conf
sed -e "s/\${IP}/$IP/g" logstash/pipelines/pipeline_metricbeat.template.conf > logstash/pipelines/pipeline_metricbeat.conf


# Arrancamos el cluster de Elastic y Kibana
cd elastic-kibana
./init.sh

echo "Cluster de elasticSearch arrancando"
echo "  Kibana estará disponible en https://localhost:8082"
echo "  Cerebro estarádisponible en http://localhost:8081"
echo "   Usuario: elastic"
echo "   Password: password"

echo "Esperando al arranque de los elastic"
sleep 80

# Arrancamos logstash
cd ../logstash
./init.sh

# Arrancamos Apache
cd ../apache
./init.sh

echo "Apache y monitorizadores arrancando"
echo "  Apache esta disponible en https://localhost:8080"

