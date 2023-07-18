package com.mobilebcs.configuration;

import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import java.lang.reflect.Type;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;

public class ClientScoreJobNotificationStompHandler implements StompSessionHandler {

    private final StompSessionHandler stompSessionHandler;
    public ClientScoreJobNotificationStompHandler(StompSessionHandler stompSessionHandler) {
        this.stompSessionHandler=stompSessionHandler;
    }

    @Override
    public void afterConnected(StompSession session, StompHeaders connectedHeaders) {

    }

    @Override
    public void handleException(StompSession session, StompCommand command, StompHeaders headers, byte[] payload, Throwable exception) {

    }

    @Override
    public void handleTransportError(StompSession session, Throwable exception) {

    }

    @Override
    public Type getPayloadType(StompHeaders headers) {
        return ScoreJobNotification.class;
    }

    @Override
    public void handleFrame(StompHeaders headers, Object payload) {
        if(payload instanceof ScoreJobNotification){

            stompSessionHandler.handleFrame(headers,payload);
        }
    }
}
