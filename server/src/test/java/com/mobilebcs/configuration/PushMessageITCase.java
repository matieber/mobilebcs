package com.mobilebcs.configuration;

import com.mobilebcs.ServerApp;
import com.mobilebcs.domain.NextCaravanMessage;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jms.core.JmsTemplate;;
import org.springframework.test.context.ActiveProfiles;

@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Disabled
public class PushMessageITCase {

    @Autowired
    private JmsTemplate jmsTemplate;

    @Value("${images.queue.name}")
    private String queueName;

    @Test
    public void testSendImagesToQueue()  {
        Integer position1 = 1;

        jmsTemplate.convertAndSend(queueName,new NextCaravanMessage(position1));
        Integer position2 = 2;
        jmsTemplate.convertAndSend(queueName,new NextCaravanMessage(position2));


    }


}
