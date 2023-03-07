package com.mobilebcs.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.converter.SimpleMessageConverter;
import org.springframework.messaging.simp.stomp.StompSessionHandler;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;
import org.springframework.web.socket.sockjs.client.SockJsClient;
import org.springframework.web.socket.sockjs.client.Transport;
import org.springframework.web.socket.sockjs.client.WebSocketTransport;

import javax.websocket.ContainerProvider;
import javax.websocket.WebSocketContainer;
import java.util.ArrayList;
import java.util.List;

@Configuration
public class ViewerClientConfiguration {


    @Bean
    public WebSocketClient webSocketClient() {
        StandardWebSocketClient standardWebSocketClient = new StandardWebSocketClient();
        List<Transport> transports = new ArrayList<Transport>();
        WebSocketContainer container = ContainerProvider.getWebSocketContainer();
        container.setDefaultMaxTextMessageBufferSize(512*2024);  //FIX
        WebSocketClient wsClient = new StandardWebSocketClient(container);
        transports.add(new WebSocketTransport(wsClient));
//      transports.add(new RestTemplateXhrTransport());

        SockJsClient sockJsClient = new SockJsClient(transports);
        WebSocketStompClient stompClient = new WebSocketStompClient(sockJsClient);
        stompClient.setMessageConverter(new SimpleMessageConverter());
        stompClient.setInboundMessageSizeLimit(512 * 2024);      //FIX
        return standardWebSocketClient;
    }


}
