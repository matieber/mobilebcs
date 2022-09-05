package com.mobilebcs;

import com.mobilebcs.controller.user.User;
import com.mobilebcs.domain.NextCaravanMessage;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;

import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.test.context.ActiveProfiles;


@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class QualifierITCase extends AbstractITCase {


    @LocalServerPort
    private Long randomServerPort;

    @Value("${activemq.brokerUrl}")
    private String brokerUrl;

    @Value("${images.queue.name}")
    private String queueName;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private JmsTemplate jmsTemplate;




    @Test
    public void testMultipleQualifiers() {

        int position1 = 1;
        int position2 = 2;
        String name1="qualifier1";
        String name2="qualifier2";
        String name3="qualifier3";
        startUserSession(name1);
        startUserSession(name2);
        sendMessage(position1, queueName);
        sendMessage(position2, queueName);



        System.out.println("Llamada 1");
        testNextJob(name1,1);
        testNextJob(name1,2);
        testNextJob(name1,null);


        testNextJob(name2,1);
        testNextJob(name2,2);
        testNextJob(name2,null);


        int position3 = 3;
        startUserSession(name3);
        sendMessage(position3, queueName);
        testNextJob(name1,position3);
        testNextJob(name1,null);
        testNextJob(name2,position3);
        testNextJob(name2,null);

        testNextJob(name3,position3);
        testNextJob(name3,null);
    }

    private void sendMessage(int position, String destinationName) {
        jmsTemplate.convertAndSend(destinationName,new NextCaravanMessage(position));
    }

    @Test
    public void testQualifier() {
        String name="qualifier1";
        startUserSession(name);
        sendMessage(1, queueName);
        sendMessage(2, queueName);



        testNextJob(name, 1);
        testNextJob(name, 2);
        testNextJob(name, null);


    }

    private void testNextJob(String name, Integer position) {
        ResponseEntity<NextCaravanMessage> entity = restTemplate.getForEntity("/qualifier/" + name + "/next-animal", NextCaravanMessage.class);


        if(position!=null) {
            Assertions.assertEquals(200,entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNotNull(nextCaravanMessage);
            Assertions.assertEquals(nextCaravanMessage.getPosition(), position);
        }else{
            Assertions.assertEquals(204,entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNull(nextCaravanMessage);
        }
    }


    private void startUserSession(String name) {
        ResponseEntity<User> entity = restTemplate.getForEntity("/user/" + name, User.class);
        Assertions.assertEquals(200,entity.getStatusCodeValue());
        User user = entity.getBody();
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name,user.getUsername());
    }

}
