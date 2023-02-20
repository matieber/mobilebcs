package com.mobilebcs.domain.images;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.session.QueueProviderService;
import com.mobilebcs.domain.user.UserQueue;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import javax.jms.JMSException;
import javax.jms.Message;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

@Component
public class ImagesListener {

    private final JmsTemplate jmsTemplate;

    private final QueueProviderService queueProviderService;

    private SimpMessagingTemplate simpMessagingTemplate;



    public ImagesListener(JmsTemplate jmsTemplate, QueueProviderService queueProviderService, SimpMessagingTemplate simpMessagingTemplate) {
        this.jmsTemplate = jmsTemplate;
        this.queueProviderService = queueProviderService;

        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    @JmsListener(destination = "${images.queue.name}", containerFactory = "jmsListenerContainerFactory")
    public void listener(Message message) throws JMSException, ExecutionException, InterruptedException, TimeoutException {

        NextCaravanMessage nextCaravanMessage = (NextCaravanMessage) jmsTemplate.getMessageConverter().fromMessage(message);
        sentJobToQualifier(message, nextCaravanMessage);
        sentJobToViewers(nextCaravanMessage);
        message.acknowledge();
    }

    private void sentJobToViewers(NextCaravanMessage nextCaravanMessage) throws ExecutionException, InterruptedException, TimeoutException {
        Long qualificationSession = queueProviderService.getQualificationSession(nextCaravanMessage.getLocationCode());
        JobNotificationOutput jobNotificationOutput = new JobNotificationOutput(nextCaravanMessage.getPosition(),nextCaravanMessage.getImages());

        //this.simpMessagingTemplate.convertAndSend("/topic/notifications/"+qualificationSession, jobNotificationOutput);
        System.out.println("sending to queue viewers: " + jobNotificationOutput);
        this.simpMessagingTemplate.convertAndSend("/topic/notifications", jobNotificationOutput);

    }

    private void sentJobToQualifier(Message message, NextCaravanMessage nextCaravanMessage) {
        Set<UserQueue> queues = queueProviderService.getQueues(nextCaravanMessage.getLocationCode());
        for (UserQueue userQueue : queues) {
            try {
                String queueName = userQueue.getQueueName();
                System.out.println("sending to queue " + queueName + " from topic with body: " + message.getBody(String.class));
                jmsTemplate.convertAndSend(queueName, nextCaravanMessage);
            } catch (JMSException e) {
                throw new RuntimeException(e);
            }
        }
    }


}
