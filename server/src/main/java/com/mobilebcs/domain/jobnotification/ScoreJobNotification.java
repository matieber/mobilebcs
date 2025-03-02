package com.mobilebcs.domain.jobnotification;


import java.util.UUID;

public class ScoreJobNotification {

    private String identification;
    private UUID setCode;
    private String location;
    private Integer position;

    private Double score;
    private String predictor;


    private ScoreJobNotification() {
    }

    public ScoreJobNotification(String identification,UUID setCode, Integer position, String location, Double score, String predictor) {
        this.identification = identification;
        this.setCode = setCode;
        this.location=location;
        this.position = position;
        this.score=score;
        this.predictor=predictor;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public String getPredictor() {
        return predictor;
    }

    public void setPredictor(String predictor) {
        this.predictor = predictor;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public UUID getSetCode() {
        return setCode;
    }


    public String getIdentification() {
        return identification;
    }

    public void setIdentification(String identification) {
        this.identification = identification;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("ScoreJobNotification{");
        sb.append("uuid='").append(setCode).append('\'');
        sb.append("location='").append(location).append('\'');
        sb.append(", position=").append(position);
        sb.append(", score=").append(score);
        sb.append(", predictor='").append(predictor).append('\'');
        sb.append(", identification='").append(identification).append('\'');
        sb.append('}');
        return sb.toString();
    }
}
