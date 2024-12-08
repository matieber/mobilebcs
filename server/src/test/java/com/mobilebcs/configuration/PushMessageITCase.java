package com.mobilebcs.configuration;

import com.mobilebcs.RestCaller;
import com.mobilebcs.configuration.jms.JmsAutoConfiguration;
import com.mobilebcs.configuration.jms.JmsProperties;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.images.ImageEncoder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jms.core.JmsTemplate;;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.io.File;

import java.io.IOException;

import org.testcontainers.shaded.org.apache.commons.lang.RandomStringUtils;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = {JmsProperties.class, JmsAutoConfiguration.class})
@TestPropertySource(properties = {"activemq.username=admin",
        "activemq.password=admin",
        "activemq.brokerUrl=tcp://localhost:61616",
        "activemq.receive-timeout=10000","images.queue.name=IMAGE_QUEUE"})
@Disabled
public class PushMessageITCase {
    private RestCaller restCaller;

    private String locationCode="DEFAULT";

    private Map<Integer, String> map;
    @BeforeEach
    public void init(){
        map = new HashMap<>();
        map.put(1, "UHSJQ3");
        map.put(2, "GSVQMB");
        map.put(3, "9ZF1TV");
        map.put(4, "GG8CWT");
        map.put(5, "TEURMB");
        map.put(6, "BYHRFV");
        map.put(7, "AJ2RIR");
        map.put(8, "DT4NWA");
        map.put(9, "IFFVM7");
        map.put(10, "7749T6");
        map.put(11, "RW674H");
        map.put(12, "RSVZ1B");
        map.put(13, "ZHBMMB");
        map.put(14, "MQ8ABZ");
        map.put(15, "7PSFVM");
    }

    @Test
    public void testSendImagesToQueue() throws InterruptedException, IOException {
        restCaller=new RestCaller(8080,"localhost");
        //int initial;for(int j=0;j<116;j++) {
        int initial;for(int j=3;j<4;j++) {
            initial=15*j;
            for (int i = 6; i <= 6; i++) {
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

                System.out.println(LocalDateTime.now().format(dtf) + " Sending image " + (initial+i) + " to queue " + map.get(i));
                restCaller.sendRealImage(i, locationCode, map.get(i),initial+i);
                Thread.sleep(3000);
            }
        }
    }
}