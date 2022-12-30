package com.mobilebcs.domain.jobnotification;

public class JobNotificationOutput {

    private Integer position;


    private JobNotificationOutput() {
    }

    public JobNotificationOutput(Integer position) {
        this.position = position;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }
}
