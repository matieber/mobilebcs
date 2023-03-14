package com.mobilebcs.domain.user;

public class UserQualificationSession {

    private long userId;
    private long qualificationSessionId;

    public UserQualificationSession(long userId, long qualificationSessionId) {
        this.userId = userId;
        this.qualificationSessionId = qualificationSessionId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public long getQualificationSessionId() {
        return qualificationSessionId;
    }

    public void setQualificationSessionId(long qualificationSessionId) {
        this.qualificationSessionId = qualificationSessionId;
    }
}
