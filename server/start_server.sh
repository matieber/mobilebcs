#!/bin/bash

# Inicia los servicios con Docker Compose
echo "Iniciando servicios con Docker Compose..."
docker-compose up -d

# Espera a que MySQL esté listo
echo "Esperando a que MySQL esté listo..."
until docker exec -it mysql-db mysql -uroot -proot -e "SELECT 1;" &>/dev/null; do
    echo "MySQL aún no está listo. Reintentando en 5 segundos..."
    sleep 5
done

echo "MySQL está listo. Creando la base de datos 'server'..."
docker exec -it mysql-db mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS server;"

# Ejecuta la aplicación Java
echo "Iniciando la aplicación Java..."
java -jar target/server.jar

echo "Todo listo. Servicios y aplicación en ejecución."
