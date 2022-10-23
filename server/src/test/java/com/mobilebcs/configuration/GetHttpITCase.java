package com.mobilebcs.configuration;

import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;

import org.springframework.web.reactive.function.client.WebClient;

import javax.jms.JMSException;

@Disabled
public class GetHttpITCase  {


    @LocalServerPort
    private Long randomServerPort;


    private String brokerUrl;


    private WebClient client;

    @BeforeEach
  public void init(){
      client= WebClient.create("http://localhost:"+8080);
  }

    @Test
    public void testQueue() throws InterruptedException, JMSException {
        String name="qualifier1";
        startUserSession("qualifier1");
        startUserSession("qualifier2");
        testNextJob(name, 0);
        testNextJob(name, 1);
        testNextJob(name, 2);
        testNextJob(name, 3);
        testNextJob(name, 4);
        testNextJob(name, 5);
        testNextJob(name, 6);
        testNextJob(name, 7);
        testNextJob(name, 8);
        testNextJob(name, 9);
        testNextJob(name, null);
        testNextJob("qualifier2", 0);
    }

    private void startUserSession(String name) {
        ResponseEntity<User> entity = client.get().uri("/user/" + name).retrieve().toEntity(User.class).block();
        Assertions.assertEquals(200,entity.getStatusCodeValue());
        User user = entity.getBody();
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name,user.getUsername());
    }

    private void testNextJob(String name, Integer position) {
        ResponseEntity<NextCaravanMessage> entity = client.get().uri("/qualifier/" + name + "/next-animal").retrieve().toEntity(NextCaravanMessage.class).block();


        if(position!=null) {
            Assertions.assertEquals(200,entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNotNull(nextCaravanMessage);
            Assertions.assertEquals(nextCaravanMessage.getSetId(), position);
        }else{
            Assertions.assertEquals(204,entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNull(nextCaravanMessage);
        }
    }


}
