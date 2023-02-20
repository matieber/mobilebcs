package com.mobilebcs.domain.jobnotification;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.security.Principal;


public class ViewerNotificationController {


    private final SimpMessagingTemplate simpMessagingTemplate;

    public ViewerNotificationController(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    @MessageMapping("/nextjob")
    public void send(@Payload JobNotification message) throws Exception {
        JobNotificationOutput jobNotificationOutput = new JobNotificationOutput(message.getPosition(),message.getImages());
        this.simpMessagingTemplate.convertAndSend("/topic/notifications", jobNotificationOutput);
    }

}
