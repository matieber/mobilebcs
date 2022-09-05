package com.mobilebcs.domain;

import com.mobilebcs.controller.user.User;

public class UserQueue {
    private final String queueName;
    private final User user;

    public UserQueue(String queueName, User user) {
        this.queueName=queueName;
        this.user=user;
    }

    public String getQueueName() {
        return queueName;
    }

    public User getUser() {
        return user;
    }
}
