package com.mobilebcs.configuration;

import com.mobilebcs.configuration.jms.JmsAutoConfiguration;
import com.mobilebcs.configuration.jms.JmsProperties;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.images.ImageEncoder;
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
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = {JmsProperties.class, JmsAutoConfiguration.class})
@TestPropertySource(properties = {"activemq.username=admin",
        "activemq.password=admin",
        "activemq.brokerUrl=tcp://localhost:61616",
        "activemq.receive-timeout=10000","images.queue.name=IMAGE_QUEUE"})
public class PushMessageITCase {

    public static final String IMAGE_PREFIX = "cow_images.";
    public static final String IMAGE_EXTENSION = "png";
    @Autowired
    private JmsTemplate jmsTemplate;

    @Value("${images.queue.name}")
    private String queueName;

    @TempDir
    private File path;

    private String locationCode="DEFAULT";



    @Test
    public void testSendImagesToQueue() throws InterruptedException, IOException {
        for(int i=1;i<=15;i++) {
           sendMessage(i,queueName);
           Thread.sleep(3000L);
        }

    }

    private void sendMessage(int position, String destinationName) throws IOException {
        List<byte[]> list = new ArrayList<>();
        String imageName = IMAGE_PREFIX + position;
        list.add(ImageEncoder.getImage(imageName, IMAGE_EXTENSION));
        jmsTemplate.convertAndSend(destinationName,new NextCaravanMessage(position, UUID.randomUUID(),locationCode,list));
    }



}
