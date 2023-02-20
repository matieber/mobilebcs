package com.mobilebcs.domain.jobnotification;

import java.util.List;

public class JobNotification {

    private List<byte[]> images;
    private Long qualificationSession;
    private Integer position;

    private JobNotification() {
    }

    public JobNotification(Long qualificationSession, Integer position, List<byte[]> images) {
        this.qualificationSession = qualificationSession;
        this.position = position;
        this.images=images;
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

    public List<byte[]> getImages() {
        return images;
    }

    public void setImages(List<byte[]> images) {
        this.images = images;
    }
}
