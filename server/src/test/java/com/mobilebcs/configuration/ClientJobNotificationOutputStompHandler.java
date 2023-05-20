package com.mobilebcs.configuration;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;

import java.lang.reflect.Type;

public class ClientJobNotificationOutputStompHandler implements StompSessionHandler {

    private final StompSessionHandler stompSessionHandler;
    private final StompSession stompSession;
    private final String location;
    private String viewerName;

    public ClientJobNotificationOutputStompHandler(StompSessionHandler stompSessionHandler, StompSession stompSession, String location, String viewerName) {
        this.stompSessionHandler=stompSessionHandler;
        this.stompSession = stompSession;
        this.location = location;
        this.viewerName = viewerName;
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
        if(payload instanceof JobNotificationOutput) {
            System.out.println("Handle message "+this.viewerName+" "+(((JobNotificationOutput) payload).getPosition()));
            stompSessionHandler.handleFrame(headers,payload);
            JobNotificationOutput jobNotificationOutput = (JobNotificationOutput) payload;
            if (jobNotificationOutput.getPredictor().equals(viewerName)) {
                double score = 3;
                ScoreJobNotification scoreJobNotification = new ScoreJobNotification(jobNotificationOutput.getPosition(), location, score, viewerName);

                stompSession.send("/app/score", scoreJobNotification);

            }
        }
    }
}
