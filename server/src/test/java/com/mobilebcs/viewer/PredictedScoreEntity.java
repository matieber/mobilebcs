package com.mobilebcs.viewer;

public class PredictedScoreEntity {

    private String setCode;
    private Double score;
    private Long qualificationSessionId;


    public String getSetCode() {
        return setCode;
    }

    public void setSetCode(String setCode) {
        this.setCode = setCode;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }


    public Long getQualificationSessionId() {
        return qualificationSessionId;
    }

    public void setQualificationSessionId(Long qualificationSessionId) {
        this.qualificationSessionId = qualificationSessionId;
    }
}
