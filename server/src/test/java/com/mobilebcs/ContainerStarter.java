package com.mobilebcs;

import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.JdbcDatabaseContainer;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.containers.wait.strategy.HostPortWaitStrategy;
import org.testcontainers.containers.wait.strategy.Wait;

import java.time.Duration;

public class ContainerStarter {

    private static final String TCP_FORMAT = "tcp://%s:%d";
    private static final String ACTIVEMQ_IMAGE = "quay.io/artemiscloud/activemq-artemis-broker";
    private static final Integer ACTIVEMQ_PORT = 61616;

    private static final String MYSQL_IMAGE = "mysql:8.0";
    private static final Integer MYSQL_PORT = 3306;
    private static final String MYSQL_USERNAME = "root";
    private static final String MYSQL_PASSWORD = "root";

    private static GenericContainer<?> activemq;

    private static JdbcDatabaseContainer<?> mysql;


    public static final String DATABASE_NAME = "server";

    public static final String AMQ_USER_PROPERTY = "AMQ_USER";

    public static final String AMQ_PASSWORD_PROPERTY = "AMQ_PASSWORD";

    public static final String AMQ_USER = "admin";
    public static final String AMQ_PASSWORD = "admin";

    public static GenericContainer startActiveMq() {
        if (activemq == null) {
            activemq = new GenericContainer<>(ACTIVEMQ_IMAGE)
                    .withExposedPorts(ACTIVEMQ_PORT)
                    .withEnv(AMQ_USER_PROPERTY, AMQ_USER)
                    .withEnv(AMQ_PASSWORD_PROPERTY, AMQ_PASSWORD)
                    .waitingFor(new HostPortWaitStrategy())
                    .withReuse(false);
            activemq.start();
        }
        return activemq;
    }

    public static JdbcDatabaseContainer startMysql() {
        if (mysql == null) {
            mysql = new MySQLContainer<>(MYSQL_IMAGE)
                    .withUsername(MYSQL_USERNAME)
                    .withPassword(MYSQL_PASSWORD)
                    .withDatabaseName(DATABASE_NAME)
                    .withExposedPorts(MYSQL_PORT)
                    .waitingFor(Wait.forListeningPort())
                    .withStartupTimeout(Duration.ofMinutes(5));
            mysql.start();
        }
        return mysql;
    }

    public static GenericContainer getActiveMQ() {
        return activemq;
    }

    public static JdbcDatabaseContainer getMySQL() {
        return mysql;
    }

    public static String getBrokerUrl() {
        var ip = ContainerStarter.getActiveMQ().getContainerIpAddress();
        var firstMappedPort = ContainerStarter.getActiveMQ().getFirstMappedPort();
        return String.format(TCP_FORMAT, ip, firstMappedPort);
    }
}
