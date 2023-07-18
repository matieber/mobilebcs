package com.mobilebcs.viewer;

import org.springframework.messaging.simp.stomp.StompSession;

class SubscribedViewer {

    public final StompSession.Subscription subscribe;
    public final String viewer;
    public final StompSession.Subscription subscribeScore;
    public final StompSession stompSession;

    public SubscribedViewer(StompSession.Subscription subscribe, String viewer, StompSession.Subscription subscribeScore, StompSession stompSession) {
        this.subscribe = subscribe;
        this.viewer = viewer;
        this.subscribeScore = subscribeScore;
        this.stompSession = stompSession;
    }
}
