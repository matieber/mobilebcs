package com.mobilebcs.domain.session;

public class QueueNameBuilder {
    public static String createQueueName(long qualificationSessionId, String username) {
        return qualificationSessionId + "-" + username;
    }
}
