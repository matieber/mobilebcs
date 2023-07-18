package com.mobilebcs.controller.caravan;

public class CaravanQualificationResponse {

    private double score;
    private long qualificationSessionId;

    private CaravanQualificationResponse(){}
    public CaravanQualificationResponse(double score, long qualificationSessionId) {
        this.score = score;
        this.qualificationSessionId = qualificationSessionId;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public long getQualificationSessionId() {
        return qualificationSessionId;
    }

    public void setQualificationSessionId(long qualificationSessionId) {
        this.qualificationSessionId = qualificationSessionId;
    }
}
