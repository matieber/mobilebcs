package com.mobilebcs.configuration;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;

import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

public class ClientJobNotificationOutputStompHandler implements StompSessionHandler {

    private final StompSessionHandler stompSessionHandler;
    private final StompSession stompSession;
    private final String location;
    private String viewerName;

    private Map<UUID,Double> scores=new HashMap<>();

    public ClientJobNotificationOutputStompHandler(StompSessionHandler stompSessionHandler, StompSession stompSession, String location, String viewerName) {
        this.stompSessionHandler=stompSessionHandler;
        this.stompSession = stompSession;
        this.location = location;
        this.viewerName = viewerName;
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
        return JobNotificationOutput.class;
    }

    @Override
    public void handleFrame(StompHeaders headers, Object payload) {
        if(payload instanceof JobNotificationOutput) {

            stompSessionHandler.handleFrame(headers,payload);
            JobNotificationOutput jobNotificationOutput = (JobNotificationOutput) payload;
            if (jobNotificationOutput.getPredictor().equals(viewerName)) {
                double score = ThreadLocalRandom.current().nextDouble(0, 5);
                score=round(score,3);

                scores.put(jobNotificationOutput.getSetCode(),score);
                ScoreJobNotification scoreJobNotification = new ScoreJobNotification(jobNotificationOutput.getSetCode(), jobNotificationOutput.getPosition(), location, score, viewerName);

                stompSession.send("/app/score", scoreJobNotification);

            }
        }
    }

    private static double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();

        BigDecimal bd = new BigDecimal(Double.toString(value));
        bd = bd.setScale(places, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }

    public Map<UUID,Double> getScores() {
        return scores;
    }
}
