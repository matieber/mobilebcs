package com.mobilebcs;

import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.lang.NonNull;
import org.springframework.test.context.ContextConfiguration;

@ContextConfiguration(initializers = AbstractITCase.Initializer.class)
public abstract class AbstractITCase {


    private static final String BROKER_URL_FORMAT = "activemq.brokerUrl=%s";

    private static final String MYSQL_USERNAME = "root";
    private static final String MYSQL_PASSWORD = "root";


    private static final String DATASOURCE_DRIVER_PROPERTY = "spring.datasource.driver-class-name";
    private static final String DATASOURCE_URL_PROPERTY = "spring.datasource.url";
    private static final String DATASOURCE_USERNAME_PROPERTY = "spring.datasource.username";
    private static final String DATASOURCE_PASSWORD_PROPERTY = "spring.datasource.password";

    private static final String DATASOURCE_SCHEMA_PROPERTY = "datasource.schema";


    static {
        ContainerStarter.startActiveMq();
        ContainerStarter.startMysql();
    }

    static class Initializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {
        @Override
        public void initialize(@NonNull ConfigurableApplicationContext configurableApplicationContext) {
            var url = ContainerStarter.getBrokerUrl();
            var property = String.format(BROKER_URL_FORMAT, url);
            TestPropertyValues.of(property).applyTo(configurableApplicationContext);


            System.setProperty(DATASOURCE_DRIVER_PROPERTY, ContainerStarter.getMySQL().getDriverClassName());
            System.setProperty(DATASOURCE_URL_PROPERTY, ContainerStarter.getMySQL().getJdbcUrl());
            System.setProperty(DATASOURCE_USERNAME_PROPERTY, MYSQL_USERNAME);
            System.setProperty(DATASOURCE_PASSWORD_PROPERTY, MYSQL_PASSWORD);
            System.setProperty(DATASOURCE_SCHEMA_PROPERTY, ContainerStarter.getMySQL().getDatabaseName());
        }
    }
}
