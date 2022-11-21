package com.mobilebcs.domain.session;

public class UserQueueEntity {

    private Long qualificationSessionId;
    private String userName;
    private String type;

    public void setQualificationSessionId(Long qualificationSessionId) {
        this.qualificationSessionId = qualificationSessionId;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setType(String type) {
        this.type = type;
    }

    public long getQualificationSessionId() {
        return qualificationSessionId;
    }

    public String getUserName() {
        return userName;
    }

    public String getType() {
        return type;
    }
}
