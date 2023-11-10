package com.mobilebcs.viewer;

import com.mobilebcs.configuration.ClientJobNotificationOutputStompHandler;
import org.springframework.messaging.simp.stomp.StompSession;

class SubscribedViewer {

    public final StompSession.Subscription subscribe;
    public final String viewer;
    public final StompSession.Subscription subscribeScore;
    public final StompSession stompSession;

    public final ClientJobNotificationOutputStompHandler clientJobNotificationOutputStompHandler;

    public SubscribedViewer(StompSession.Subscription subscribe, String viewer, StompSession.Subscription subscribeScore, StompSession stompSession, ClientJobNotificationOutputStompHandler clientJobNotificationOutputStompHandler) {
        this.subscribe = subscribe;
        this.viewer = viewer;
        this.subscribeScore = subscribeScore;
        this.stompSession = stompSession;
        this.clientJobNotificationOutputStompHandler =clientJobNotificationOutputStompHandler;
    }
}
