package com.mobilebcs;

public class UserQualificationSessionEntity {

    private String userName;
    private long qualificationSessionId;

    public UserQualificationSessionEntity(){}

    public UserQualificationSessionEntity(String userName, long qualificationSessionId) {
        this.userName = userName;
        this.qualificationSessionId = qualificationSessionId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public long getQualificationSessionId() {
        return qualificationSessionId;
    }

    public void setQualificationSessionId(long qualificationSessionId) {
        this.qualificationSessionId = qualificationSessionId;
    }
}
