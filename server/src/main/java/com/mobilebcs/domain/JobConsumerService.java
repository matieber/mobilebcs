package com.mobilebcs.domain;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;

import javax.jms.JMSException;
import javax.jms.Message;

@Service
public class JobConsumerService {

    private final QualifierQueueFactory qualifierQueueFactory;

    private final JmsTemplate jmsTemplate;

    public JobConsumerService(QualifierQueueFactory qualifierQueueFactory, @Qualifier("listenerQueueJmsTemplate") JmsTemplate jmsTemplate) {
        this.qualifierQueueFactory = qualifierQueueFactory;
        this.jmsTemplate = jmsTemplate;
    }

    public NextCaravanMessage nextJob(String userName) throws UserNonexistentException, InvalidOperationException, JMSException {
        UserQueue queue = qualifierQueueFactory.getQueue(userName);
        if(queue==null){
            throw new InvalidOperationException("El calificador "+userName+" no ha registrado para calificar");
        }

        return (NextCaravanMessage) jmsTemplate.receiveAndConvert(queue.getQueueName());
    }
}
