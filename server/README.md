Cola:
docker run -p 61616:61616 -e AMQ_USER=admin -e AMQ_PASSWORD=admin quay.io/artemiscloud/activemq-artemis-broker

docker run -d -p 3306:3306 --name mysql-db -e MYSQL_ROOT_PASSWORD=sysone mysql:5.7