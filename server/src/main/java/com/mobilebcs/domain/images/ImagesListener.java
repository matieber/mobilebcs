package com.mobilebcs.domain.images;

import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.session.QueueProviderService;
import com.mobilebcs.domain.user.UserQueue;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

import javax.jms.JMSException;
import javax.jms.Message;
import java.util.Set;

@Component
public class ImagesListener {

    private final JmsTemplate jmsTemplate;

    private final QueueProviderService queueProviderService;

    //private final StompSession stompSession;


    public ImagesListener(JmsTemplate jmsTemplate, QueueProviderService queueProviderService/*, @Qualifier("serverStompSession") StompSession stompSession*/) {
        this.jmsTemplate = jmsTemplate;
        this.queueProviderService = queueProviderService;
        //      this.stompSession = stompSession;
    }

    @JmsListener(destination = "${images.queue.name}", containerFactory = "jmsListenerContainerFactory")
    public void listener(Message message) throws JMSException {

        NextCaravanMessage nextCaravanMessage = (NextCaravanMessage) jmsTemplate.getMessageConverter().fromMessage(message);
        sentJobToViewers(nextCaravanMessage);
        sentJobToQualifier(message, nextCaravanMessage);
        message.acknowledge();
        System.out.println("There are not qualifier to receive the job");
    }

    private void sentJobToViewers(NextCaravanMessage nextCaravanMessage) {
        Long qualificationSession = queueProviderService.getQualificationSession(nextCaravanMessage.getLocationCode());
        //    stompSession.send("/app/nextjob", new JobNotification(qualificationSession, nextCaravanMessage.getPosition()));

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
