package com.mobilebcs.configuration;

import com.mobilebcs.domain.NextCaravanMessage;
import org.springframework.jms.annotation.JmsListener;


public class JsonListener {

    @JmsListener(destination = "image.topic", containerFactory = "topicListenerFactory")
    public void receiveTopicMessage(NextCaravanMessage image) {
        System.out.println("Received to topic <" + image.getPosition() + ">");
    }

    @JmsListener(destination = "image.queue", containerFactory = "queueListenerFactory")
    public void receiveQueueMessage(NextCaravanMessage image ) {
        System.out.println("Received to queue <" + image.getPosition()  + ">");
    }
}
