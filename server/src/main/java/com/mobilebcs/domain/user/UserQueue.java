package com.mobilebcs.domain.user;

import java.util.Objects;

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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserQueue userQueue = (UserQueue) o;
        return Objects.equals(queueName, userQueue.queueName) && Objects.equals(user, userQueue.user);
    }

    @Override
    public int hashCode() {
        return Objects.hash(queueName, user);
    }
}
