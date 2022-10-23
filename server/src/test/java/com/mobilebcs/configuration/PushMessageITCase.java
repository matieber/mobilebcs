package com.mobilebcs.configuration;

import com.mobilebcs.domain.qualifier.NextCaravanMessage;
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

import java.util.UUID;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = {JmsProperties.class, JmsAutoConfiguration.class})
@TestPropertySource(properties = {"activemq.username=admin",
        "activemq.password=admin",
        "activemq.brokerUrl=tcp://localhost:61616",
        "activemq.receive-timeout=10000","images.queue.name=IMAGE_QUEUE"})
@Disabled
public class PushMessageITCase {

    @Autowired
    private JmsTemplate jmsTemplate;

    @Value("${images.queue.name}")
    private String queueName;

    @TempDir
    private File path;

    private String locationCode="DEFAULT";

    @Test
    public void testSendImagesToQueue()  {
        for(int i=0;i<10;i++) {
           sendMessage(i,queueName);
        }

    }

    private void sendMessage(int position, String destinationName) {
        jmsTemplate.convertAndSend(destinationName,new NextCaravanMessage(position, UUID.randomUUID(),locationCode));
    }



}
