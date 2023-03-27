package com.mobilebcs.controller.qualifier;


public class QualificationRequest {

    private int score;

    private QualificationRequest(){}

    public QualificationRequest(int score) {
        this.score = score;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }
}
