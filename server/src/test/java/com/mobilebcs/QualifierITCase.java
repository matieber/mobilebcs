package com.mobilebcs;

import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;

import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;

import java.io.File;

import java.util.UUID;


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



    private String locationCode;

    @TempDir
    private File path;
    @BeforeEach
    public void init(){
        locationCode ="DEFAULT";
    }

    @Test
    @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD)
    public void testMultipleQualifiers() {


        String name1="qualifier1";
        String name2="qualifier2";
        String name3="qualifier3";
        long qualificationSession = startQualificationSession(name1, null);
        startQualificationSession(name2,qualificationSession);
        for(int position= 0;position < 10; position++){
            sendMessage(position, queueName);
        }

        System.out.println("Llamada 1");
        for(int position= 0;position < 10; position++){
            testNextJob(name1,position);
        }
        testNextJob(name1,null);


        for(int position= 0;position < 10; position++){
            testNextJob(name2,position);
        }
        testNextJob(name2,null);


        int position10 = 10;
        startQualificationSession(name3,qualificationSession);
        sendMessage(position10, queueName);
        testNextJob(name1,position10);
        testNextJob(name1,null);
        testNextJob(name2,position10);
        testNextJob(name2,null);

        testNextJob(name3,position10);
        testNextJob(name3,null);
    }

    private void sendMessage(int position, String destinationName) {
        jmsTemplate.convertAndSend(destinationName,new NextCaravanMessage(position,UUID.randomUUID(), locationCode));
    }

    @Test
    @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD)
    public void testQualifier() {
        String name="qualifier1";
        startQualificationSession(name,null);
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
            Assertions.assertEquals(position,nextCaravanMessage.getPosition());
        }else{
            Assertions.assertEquals(204,entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNull(nextCaravanMessage);
        }
    }


    private long startQualificationSession(String name, Long qualificationSession) {
        ResponseEntity<UserResponse> entity;
        if(qualificationSession==null) {
            entity = restTemplate.postForEntity("/user/" + name + "/qualificationSession",null, UserResponse.class);
        }else{
            entity = restTemplate.postForEntity("/user/" + name + "/qualificationSession?qualificationSession="+qualificationSession,null, UserResponse.class);
        }
        Assertions.assertEquals(200,entity.getStatusCodeValue());
        UserResponse user = entity.getBody();
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name,user.getUsername());
        return user.getQualificationSession();
    }

}
