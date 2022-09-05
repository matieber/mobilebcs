package com.mobilebcs;

import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.lang.NonNull;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.JdbcDatabaseContainer;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.containers.wait.strategy.HostPortWaitStrategy;
import org.testcontainers.containers.wait.strategy.Wait;

import java.time.Duration;

@ContextConfiguration(initializers = AbstractITCase.Initializer.class)
public abstract class AbstractITCase {

    private static final String ACTIVEMQ_IMAGE = "quay.io/artemiscloud/activemq-artemis-broker";
    private static final Integer ACTIVEMQ_PORT = 61616;
    private static final String TCP_FORMAT = "tcp://%s:%d";
    private static final String BROKER_URL_FORMAT = "activemq.brokerUrl=%s";

    private static final String MYSQL_IMAGE = "mysql:8.0";
    private static final Integer MYSQL_PORT = 3306;
    private static final String MYSQL_USERNAME = "root";
    private static final String MYSQL_PASSWORD = "sysone";

    private static final GenericContainer<?> ACTIVEMQ;

    private static JdbcDatabaseContainer<?> MYSQL;


    private static final String DATASOURCE_DRIVER_PROPERTY = "spring.datasource.driver-class-name";
    private static final String DATASOURCE_URL_PROPERTY = "spring.datasource.url";
    private static final String DATASOURCE_USERNAME_PROPERTY = "spring.datasource.username";
    private static final String DATASOURCE_PASSWORD_PROPERTY = "spring.datasource.password";

    private static final String DATASOURCE_SCHEMA_PROPERTY = "datasource.schema";


    public static final String DATABASE_NAME = "server";

    public static final String AMQ_USER_PROPERTY = "AMQ_USER";

    public static final String AMQ_PASSWORD_PROPERTY = "AMQ_PASSWORD";

    public static final String AMQ_USER = "admin";
    public static final String AMQ_PASSWORD = "admin";

    static {
        ACTIVEMQ = new GenericContainer<>(ACTIVEMQ_IMAGE)
                .withExposedPorts(ACTIVEMQ_PORT)
                .withEnv(AMQ_USER_PROPERTY, AMQ_USER)
                .withEnv(AMQ_PASSWORD_PROPERTY, AMQ_PASSWORD)
                .waitingFor(new HostPortWaitStrategy())
                .withReuse(false);
        ACTIVEMQ.start();

        MYSQL = new MySQLContainer<>(MYSQL_IMAGE)
                .withUsername(MYSQL_USERNAME)
                .withPassword(MYSQL_PASSWORD)
                .withDatabaseName(DATABASE_NAME)
                .withExposedPorts(MYSQL_PORT)
                .waitingFor(Wait.forListeningPort())
                .withStartupTimeout(Duration.ofMinutes(5));
        MYSQL.start();
    }

    static class Initializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {
        @Override
        public void initialize(@NonNull ConfigurableApplicationContext configurableApplicationContext) {
            var ip = ACTIVEMQ.getContainerIpAddress();
            var firstMappedPort = ACTIVEMQ.getFirstMappedPort();
            var url = String.format(TCP_FORMAT, ip, firstMappedPort);
            var property = String.format(BROKER_URL_FORMAT, url);
            TestPropertyValues.of(property).applyTo(configurableApplicationContext);


            System.setProperty(DATASOURCE_DRIVER_PROPERTY, MYSQL.getDriverClassName());
            System.setProperty(DATASOURCE_URL_PROPERTY, MYSQL.getJdbcUrl());
            System.setProperty(DATASOURCE_USERNAME_PROPERTY, MYSQL_USERNAME);
            System.setProperty(DATASOURCE_PASSWORD_PROPERTY, MYSQL_PASSWORD);
            System.setProperty(DATASOURCE_SCHEMA_PROPERTY, MYSQL.getDatabaseName());
        }
    }
}
