# Crear volumenes
rm -f ~/environment/datos/access_log
touch ~/environment/datos/access_log
docker-compose down

sleep 3

chmod 644 heartbeat/heartbeat.yml 

# Arrancar el apache
docker-compose up -d