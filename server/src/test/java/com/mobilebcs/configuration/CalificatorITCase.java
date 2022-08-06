package com.mobilebcs.configuration;

import com.mobilebcs.ServerApp;
import com.mobilebcs.controller.user.User;
import com.mobilebcs.domain.NextCaravanMessage;
import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;

import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import javax.jms.JMSException;
import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;

@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class CalificatorITCase extends ActiveMQITCase {


    @LocalServerPort
    private Long randomServerPort;

    @Value("${activemq.brokerUrl}")
    private String brokerUrl;
    
    private WebClient client;

    @BeforeEach
  public void init(){
      client= WebClient.create("http://localhost:"+randomServerPort);
  }

    @Test
    public void testTopicSubsriptionName() throws InterruptedException, JMSException {
        Integer position1 = 1;
        JmsTemplate jmsTemplate= create();
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position1));
        Integer position2 = 2;
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position2));

        String name="calificator1";
        startUserSession(name);

        System.out.println("Llamada 1");
        List<NextCaravanMessage> list = testCalificator(name, 2);
        Assertions.assertEquals(2,list.size());
        Assertions.assertEquals(position1,list.get(0).getPosition());
        Assertions.assertEquals(position2,list.get(1).getPosition());
        name="calificator2";
        startUserSession(name);
        System.out.println("Llamada 2");
        List<NextCaravanMessage> list2 = testCalificator( name, 2);
        Assertions.assertEquals(2,list2.size());
        Assertions.assertEquals(position1,list2.get(0).getPosition());
        Assertions.assertEquals(position2,list2.get(1).getPosition());

        name="calificator1";
        Integer position3=3;
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position3));
        List<NextCaravanMessage> list3 = testCalificator(name, 1);
        Assertions.assertEquals(1,list3.size());
        Assertions.assertEquals(position3,list3.get(0).getPosition());

        name="calificator3";
        startUserSession(name);
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position3));
        List<NextCaravanMessage> list4 = testCalificator(name, 3);
        Assertions.assertEquals(3,list4.size());
        Assertions.assertEquals(position1,list4.get(0).getPosition());
        Assertions.assertEquals(position2,list4.get(1).getPosition());
        Assertions.assertEquals(position3,list4.get(2).getPosition());

    }

    @Test
    public void testFlux() throws InterruptedException, JMSException {
        Integer position1 = 1;
        JmsTemplate jmsTemplate= create();
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position1));
        Integer position2 = 2;
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position2));

        String name="calificator1";
        startUserSession(name);

        List<NextCaravanMessage> list=new ArrayList<>();
        Semaphore semaphore =new Semaphore(0);


        Flux<NextCaravanMessage> nextCaravanMessageFlux = client.get().uri("/calificator/" + name + "/next-animal")
                .accept(MediaType.TEXT_EVENT_STREAM)
                .retrieve()
                .bodyToFlux(NextCaravanMessage.class);


        nextCaravanMessageFlux.subscribe(
                nextCaravanMessage -> {
                    System.out.println(nextCaravanMessage.getPosition());
                    list.add(nextCaravanMessage);
                    semaphore.release();
                });


        semaphore.tryAcquire(2,10l,TimeUnit.SECONDS);
        Integer position3=3;
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position3));
        semaphore.tryAcquire(1,10l,TimeUnit.SECONDS);


        Assertions.assertEquals(3,list.size());
        Assertions.assertEquals(position1,list.get(0).getPosition());
        Assertions.assertEquals(position2,list.get(1).getPosition());
        Assertions.assertEquals(position3,list.get(2).getPosition());

    }



    private JmsTemplate create() throws JMSException {
            var activeMQConnectionFactory = new ActiveMQConnectionFactory();
            activeMQConnectionFactory.setBrokerURL(brokerUrl);
            activeMQConnectionFactory.setUser("admin");
            activeMQConnectionFactory.setPassword("admin");

        JmsTemplate jmsTemplate = new JmsTemplate(new CachingConnectionFactory(activeMQConnectionFactory));

        jmsTemplate.setPubSubDomain(true);

        MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
        converter.setTargetType(MessageType.TEXT);
        converter.setTypeIdPropertyName("_type");

        jmsTemplate.setMessageConverter(converter);
        return jmsTemplate;
    }

    private List<NextCaravanMessage> testCalificator(String name, int expectedMessages) throws InterruptedException {
        List<NextCaravanMessage> list=new ArrayList<>();
        Semaphore semaphore =new Semaphore(0);
        call(name, nextCaravanMessage -> {
            System.out.println(nextCaravanMessage.getPosition());
            list.add(nextCaravanMessage);
            semaphore.release();
        });
        semaphore.tryAcquire(expectedMessages,10l,TimeUnit.SECONDS);
        return list;
    }

    private void call(String name, Consumer<NextCaravanMessage> consumer) throws InterruptedException {
        Mono<ResponseEntity<Flux<NextCaravanMessage>>> responseEntityMono = client.get().uri("/calificator/" + name + "/next-animal")
                .accept(MediaType.TEXT_EVENT_STREAM)
                .retrieve()
                .toEntityFlux(NextCaravanMessage.class);

        ResponseEntity<Flux<NextCaravanMessage>> nextCaravanMessageFlux = responseEntityMono.block(Duration.of(10, ChronoUnit.SECONDS));
        Assertions.assertEquals(200,nextCaravanMessageFlux.getStatusCodeValue());
        nextCaravanMessageFlux.getBody().subscribe(consumer);

    }

    private void startUserSession(String name) {
        User user = client.get().uri("/user/" + name).accept(MediaType.APPLICATION_JSON)
                .retrieve().bodyToMono(User.class).block();
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name,user.getCalificatorUser());
    }

}
