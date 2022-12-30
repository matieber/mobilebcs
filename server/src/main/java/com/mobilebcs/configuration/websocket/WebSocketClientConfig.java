package com.mobilebcs.configuration.websocket;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.util.concurrent.ExecutionException;


public class WebSocketClientConfig {

    @Bean
    public StompSessionHandler serverStompSessionHandler() {
        return new WebSocketStompSessionHandler();
    }

    @Bean
    public WebSocketClient webSocketClient() {
        return new StandardWebSocketClient();
    }

    @Bean
    public StompSession serverStompSession(
            @Qualifier("serverStompSessionHandler") final StompSessionHandler serverStompSessionHandler,
            final WebSocketClient serverWebSocketClient,
            @Value("${server.port}") Integer port
    ) throws InterruptedException, ExecutionException {
        final WebSocketStompClient stompClient = new WebSocketStompClient(serverWebSocketClient);
        stompClient.setMessageConverter(new MappingJackson2MessageConverter());
        return stompClient.connect("ws://localhost:" + port + "/app/nextjob", serverStompSessionHandler).get();
    }
}
