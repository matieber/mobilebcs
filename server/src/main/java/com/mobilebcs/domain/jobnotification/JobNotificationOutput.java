package com.mobilebcs.domain.jobnotification;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class JobNotificationOutput {

    private UUID setCode;
    private Integer position;

    List<byte[]> images;

    private String predictor;

    private String identification;
    private Instant startTime;


    private JobNotificationOutput() {
    }

    public JobNotificationOutput(UUID setCode, Integer position, List<byte[]> images, String identification) {
        this.setCode = setCode;
        this.position = position;
        this.images=images;
        this.identification = identification;
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

    public UUID getSetCode() {
        return setCode;
    }

    public List<byte[]> getImages() {
        return images;
    }

    public String getPredictor() {
        return predictor;
    }

    public void setPredictor(String predictor) {
        this.predictor = predictor;
    }

    public String getIdentification() {
        return identification;
    }

    public void setIdentification(String identification) {
        this.identification = identification;
    }

    public void setStartTime(Instant startTime) {
        this.startTime = startTime;
    }

    public Instant getStartTime() {
        return startTime;
    }

    @Override
    public String toString() {
        return "JobNotificationOutput{" +
                "position=" + position +
                '}';
    }
}
