package com.mobilebcs.domain.qualifier;

import com.mobilebcs.domain.session.QualificationSessionService;
import com.mobilebcs.domain.user.UserQueue;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;

import javax.jms.JMSException;

@Service
public class JobConsumerService {

    private final QualifierQueueFactory qualifierQueueFactory;

    private final JmsTemplate jmsTemplate;

    private final QualificationSessionService qualificationSessionService;

    public JobConsumerService(QualifierQueueFactory qualifierQueueFactory, @Qualifier("listenerQueueJmsTemplate") JmsTemplate jmsTemplate, QualificationSessionService qualificationSessionService) {
        this.qualifierQueueFactory = qualifierQueueFactory;
        this.jmsTemplate = jmsTemplate;
        this.qualificationSessionService = qualificationSessionService;
    }

    public NextCaravanMessage nextJob(String userName) throws UserNonexistentException, InvalidOperationException, JMSException {

        UserQueue queue = qualifierQueueFactory.getQueue(userName);
        if(queue==null){
            throw new InvalidOperationException("El calificador "+userName+" no ha registrado para calificar");
        }
        return (NextCaravanMessage) jmsTemplate.receiveAndConvert(queue.getQueueName());
    }
}
