package com.mobilebcs.configuration.websocket;

import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import com.mobilebcs.domain.viewer.ViewerService;
import org.springframework.messaging.handler.annotation.MessageMapping;

import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;

@Controller
@Component
public class ScoreNotificationController {


    private final ViewerService viewerService;

    public ScoreNotificationController(ViewerService viewerService) {
        this.viewerService = viewerService;
    }



    @MessageMapping("/score")
    public void webSocketMessage(ScoreJobNotification scoreJobNotification) throws InterruptedException {
        System.out.println("new score:"+scoreJobNotification.toString());
        viewerService.sendScore(scoreJobNotification);
    }

}