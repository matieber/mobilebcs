package com.mobilebcs.configuration;

import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.lang.NonNull;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.wait.strategy.HostPortWaitStrategy;

@ContextConfiguration(initializers = ActiveMQITCase.Initializer.class)
public abstract class ActiveMQITCase {

    private static final String ACTIVEMQ_IMAGE = "quay.io/artemiscloud/activemq-artemis-broker";
    private static final Integer ACTIVEMQ_PORT = 61616;
    private static final String TCP_FORMAT = "tcp://%s:%d";
    private static final String BROKER_URL_FORMAT = "activemq.brokerUrl=%s";

    private static final GenericContainer<?> ACTIVEMQ;

    static {
        ACTIVEMQ = new GenericContainer<>(ACTIVEMQ_IMAGE)
                .withExposedPorts(ACTIVEMQ_PORT)
                .withEnv("AMQ_USER","admin")
                .withEnv("AMQ_PASSWORD","admin")
                .waitingFor(new HostPortWaitStrategy())
                .withReuse(false);
        ACTIVEMQ.start();
    }

    static class Initializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {
        @Override
        public void initialize(@NonNull ConfigurableApplicationContext configurableApplicationContext) {
            var ip = ACTIVEMQ.getContainerIpAddress();
            var firstMappedPort = ACTIVEMQ.getFirstMappedPort();
            var url = String.format(TCP_FORMAT, ip, firstMappedPort);
            var property = String.format(BROKER_URL_FORMAT, url);
            TestPropertyValues.of(property).applyTo(configurableApplicationContext);
        }
    }
}
