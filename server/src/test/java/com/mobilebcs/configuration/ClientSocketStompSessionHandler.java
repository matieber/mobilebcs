package com.mobilebcs.configuration;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;

import java.lang.reflect.Type;
import java.util.List;

public class ClientSocketStompSessionHandler implements StompSessionHandler {

    private final StompSessionHandler stompSessionHandler;

    public ClientSocketStompSessionHandler(StompSessionHandler stompSessionHandler) {
        this.stompSessionHandler=stompSessionHandler;
    }

    @Override
    public void afterConnected(StompSession session, StompHeaders connectedHeaders) {
        System.out.println("subscription connected");
    }

    @Override
    public void handleException(StompSession session, StompCommand command, StompHeaders headers, byte[] payload, Throwable exception) {
        System.out.println("subscription exception");
    }

    @Override
    public void handleTransportError(StompSession session, Throwable exception) {
        System.out.println("subscription transport error "+exception.getMessage());
    }

    @Override
    public Type getPayloadType(StompHeaders headers) {
        return JobNotificationOutput.class;
    }

    @Override
    public void handleFrame(StompHeaders headers, Object payload) {

        if(payload instanceof List){
            System.out.println("Receive list");
        }else{
            System.out.println("Receive element");
        }
        stompSessionHandler.handleFrame(headers,payload);
    }
}
