# Crear volumenes
sudo rm -rf ~/environment/datos/nodo*/*
mkdir -p ~/environment/datos/nodo{1..4}
chmod 777 -R ~/environment/datos

# Crear certificados
mkdir -p ~/environment/datos/certs
sudo rm -rf ~/environment/datos/certs/*
chmod 777 -R ~/environment/datos/certs

docker-compose run --rm create_certs 

unzip ~/environment/datos/certs/bundle.zip -d ~/environment/datos/certs

docker-compose down

sleep 3
# Arrancar el cluster
docker-compose up -d