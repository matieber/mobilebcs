package com.mobilebcs.configuration.websocket;

import com.mobilebcs.controller.DefaultExceptionHandler;
import com.mobilebcs.domain.viewer.ViewerInfo;
import com.mobilebcs.domain.viewer.ViewerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;
import org.springframework.web.socket.messaging.SessionUnsubscribeEvent;

import java.util.List;
import java.util.Map;

@Component
public class WebSocketEventListener {

    private static final Logger LOG = LoggerFactory.getLogger(WebSocketEventListener.class);

    private final ViewerService viewerService;

    public WebSocketEventListener(ViewerService viewerService) {
        this.viewerService = viewerService;
    }


    @EventListener
    private void handleDisconnection(SessionDisconnectEvent event) {
        System.out.println("removing viewer "+event.getSessionId());
        viewerService.removeViewer(event.getSessionId());
    }
/*
    @EventListener
    private void handleSessionUnsubscribe(SessionUnsubscribeEvent event) {
        System.out.println("removing viewer ");
        String simpDestination = (String) event.getMessage().getHeaders().get("simpDestination");
        String id= (String) event.getMessage().getHeaders().get("simpSessionId");
        System.out.println("adding viewer with session id "+id);
        if(simpDestination.startsWith("/topic/notifications/")&&!simpDestination.contains("score")){
            viewerService.removeViewer(id);
        }
    }
*/
    @EventListener
    private void handleSessionSubscribe(SessionSubscribeEvent event) {
        System.out.println("adding viewer ");
        String simpDestination = (String) event.getMessage().getHeaders().get("simpDestination");
        String id= (String) event.getMessage().getHeaders().get("simpSessionId");
        System.out.println("adding viewer with session id "+id);
        if(simpDestination.startsWith("/topic/notifications/")&&!simpDestination.contains("score")){
            String[] split = simpDestination.split("/");
            viewerService.addViewer(new ViewerInfo(id,split[3],split[4]));
        }
    }
}
