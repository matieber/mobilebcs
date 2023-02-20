package com.mobilebcs.domain.jobnotification;

import java.util.List;

public class JobNotificationOutput {

    private Integer position;

    List<byte[]> images;


    private JobNotificationOutput() {
    }

    public JobNotificationOutput(Integer position,List<byte[]> images) {
        this.position = position;
        this.images=images;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public void setImages(List<byte[]> images) {
        this.images=images;
    }

    public List<byte[]> getImages() {
        return images;
    }
}
