package com.mobilebcs.domain;

import com.mobilebcs.controller.user.User;
import org.springframework.stereotype.Service;

import javax.jms.JMSException;

@Service
public class UserStarterService {


    private final QualifierQueueFactory publisherFactory;

    public UserStarterService(QualifierQueueFactory publisherFactory) {
        this.publisherFactory = publisherFactory;
    }

    public User startUserSession(String name) throws UserNonexistentException, InvalidOperationException, JMSException {
            return publisherFactory.addQualifier(name);
    }
}
