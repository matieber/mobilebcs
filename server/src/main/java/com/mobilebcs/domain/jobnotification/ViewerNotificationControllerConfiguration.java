package com.mobilebcs.domain.jobnotification;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.Nullable;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.lang.reflect.Type;
import java.util.concurrent.ExecutionException;

@Configuration
public class ViewerNotificationControllerConfiguration {

    @Bean
    public ViewerNotificationController viewerNotificationController(SimpMessagingTemplate simpMessagingTemplate){
        return new ViewerNotificationController(simpMessagingTemplate);
    }

    @Bean
    public WebSocketClient serverWebSocketClient() {
        return new StandardWebSocketClient();
    }


    @Bean
    public ListenableFuture<StompSession> serverStompSession(
            final WebSocketClient serverWebSocketClient,
            @Value("${server.port}") Integer port, ViewerNotificationController viewerNotificationController
    ) throws InterruptedException, ExecutionException {
        final WebSocketStompClient stompClient = new WebSocketStompClient(serverWebSocketClient);
        stompClient.setMessageConverter(new MappingJackson2MessageConverter());

        StompSessionHandlerAdapter handler = new StompSessionHandlerAdapter() {
            @Override
            public Type getPayloadType(StompHeaders headers) {
                return super.getPayloadType(headers);
            }

            public void handleFrame(StompHeaders headers, @Nullable Object payload) {
                System.out.println("Received in Adapter server");
            }
        };
        return stompClient.connect("ws://localhost:8080/nextjob", handler);

    }
}
