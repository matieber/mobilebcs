package com.mobilebcs.domain.jobnotification;

public class JobNotification {

    private Long qualificationSession;
    private Integer position;

    private JobNotification() {
    }

    public JobNotification(Long qualificationSession, Integer position) {
        this.qualificationSession = qualificationSession;
        this.position = position;
    }

    public Long getQualificationSession() {
        return qualificationSession;
    }

    public void setQualificationSession(Long qualificationSession) {
        this.qualificationSession = qualificationSession;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }
}
