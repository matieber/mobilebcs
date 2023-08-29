package com.mobilebcs.controller.caravan;

import java.util.StringJoiner;

public class CaravanQualificationResponse {

    private double score;
    private long qualificationSessionId;

    private String setCode;

    private CaravanQualificationResponse(){}
    public CaravanQualificationResponse(double score, long qualificationSessionId, String setCode) {
        this.score = score;
        this.qualificationSessionId = qualificationSessionId;
        this.setCode=setCode;

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

    public String getSetCode() {
        return setCode;
    }

    public void setSetCode(String setCode) {
        this.setCode = setCode;
    }

    @Override
    public String toString() {
        return new StringJoiner(", ", CaravanQualificationResponse.class.getSimpleName() + "[", "]")
                .add("score=" + score)
                .add("qualificationSessionId=" + qualificationSessionId)
                .add("setCode='" + setCode + "'")
                .toString();
    }
}
