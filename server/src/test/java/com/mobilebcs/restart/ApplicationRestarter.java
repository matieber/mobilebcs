package com.mobilebcs.restart;

import com.mobilebcs.ContainerStarter;
import com.mobilebcs.ServerApp;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;
import org.testcontainers.containers.JdbcDatabaseContainer;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Semaphore;
import java.util.stream.Collectors;


@Component
public class ApplicationRestarter {

    public static final String TMP_IMAGES_TESTDATA = "/tmp/images/testdata";
    private static ConfigurableApplicationContext applicationContext;

    private static Semaphore semaphore = new Semaphore(0);

    public static void start() {
        ContainerStarter.startActiveMq();
        JdbcDatabaseContainer mysql = ContainerStarter.startMysql();
        SpringApplicationBuilder builder1 = new SpringApplicationBuilder(new Class[]{ServerApp.class});

        Map<String, Object> properties = new HashMap<>();
        properties.put("images.path", TMP_IMAGES_TESTDATA);
        properties.put("activemq.brokerUrl", ContainerStarter.getBrokerUrl());
        properties.put("spring.datasource.url", mysql.getJdbcUrl());

        
        String[] arguments = new String[0];
        arguments = properties.entrySet().stream()
                .map(entry -> new StringBuilder().append("--").append(entry.getKey()).append("=")
                        .append(entry.getValue()).toString()).collect(Collectors.toList()).toArray(arguments);
        applicationContext = builder1.run(arguments);

    }

    public static String getImagePath() {
        return TMP_IMAGES_TESTDATA;
    }

    public static void restart() throws InterruptedException {
        ApplicationArguments args = applicationContext.getBean(ApplicationArguments.class);

        Thread thread = new Thread(() -> {
            applicationContext.close();
            applicationContext = SpringApplication.run(ServerApp.class, args.getSourceArgs());
            semaphore.release();
        });

        thread.setDaemon(false);
        thread.start();
        semaphore.acquire();
    }
}
