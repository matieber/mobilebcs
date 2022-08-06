package com.mobilebcs.configuration;

import com.mobilebcs.domain.NextCaravanMessage;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

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

@Disabled
public class GetHttpITCase  {


    @LocalServerPort
    private Long randomServerPort;


    private String brokerUrl;


    private TestRestTemplate restTemplate=new TestRestTemplate();
    private WebClient client;

    @BeforeEach
  public void init(){
      client= WebClient.create("http://localhost:"+8080);
  }

    @Test
    public void testTopicSubsriptionName() throws InterruptedException, JMSException {
        String name="calificator1";
        testCalificator(name, 2);
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

}
