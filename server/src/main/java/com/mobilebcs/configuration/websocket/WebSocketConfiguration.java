package com.mobilebcs.configuration.websocket;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketTransportRegistration;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfiguration implements WebSocketMessageBrokerConfigurer {

    /**
     * Creates the in-memory message broker with one or more destinations for sending and receiving messages.
     * In the example above, there are two destination prefixes defined: topic and queue. They follow the convention
     * that destinations for messages to be carried on to all subscribed clients via the pub-sub model should be
     * prefixed with topic. On the other hand, destinations for private messages are typically prefixed by queue.
     *
     * @param config
     */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/nextjob");
    }

    @Override
    public void configureWebSocketTransport(WebSocketTransportRegistration registration) {
        registration.setMessageSizeLimit(2048 * 2048);
        registration.setSendBufferSizeLimit(2048 * 2048);
        registration.setSendTimeLimit(2048 * 2048);
    }



}
