#Documentación para el uso del projecto
## Configuración

### Iniciar cola de mensajería con docker

    docker run -p 61616:61616 -e AMQ_USER=admin -e AMQ_PASSWORD=admin quay.io/artemiscloud/activemq-artemis-broker

### Iniciar base de datos:


    docker run --name=mysql-db -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:8.0
    docker exec -it mysql-db mysql -p
    create schema server;

### Iniciar aplicación

    mvn clean install
    java -jar target/server.jar

La aplicación inicia en el puerto 8080 por defecto.