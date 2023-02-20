package com.mobilebcs.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.stomp.StompSessionHandler;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;

@Configuration
public class ViewerClientConfiguration {


    @Bean
    public WebSocketClient webSocketClient() {
        return new StandardWebSocketClient();
    }


}
