package com.mobilebcs.controller.prediction;

import java.time.LocalDateTime;

public class QualifierSessionAverageResponse {

    private Double average;
    private Double standardDeviation;
    private LocalDateTime sessionStartDate;
    private LocalDateTime sessionEndDate;
    private Long qualificationSession;

    public QualifierSessionAverageResponse(){}

    public QualifierSessionAverageResponse(double average, double standardDeviation, LocalDateTime sessionStartDate, LocalDateTime sessionEndDate, Long qualificationSession) {
        this.average = average;
        this.standardDeviation = standardDeviation;
        this.sessionStartDate = sessionStartDate;
        this.sessionEndDate = sessionEndDate;
        this.qualificationSession = qualificationSession;
    }

    public Double getAverage() {
        return average;
    }

    public void setAverage(double average) {
        this.average = average;
    }

    public Double getStandardDeviation() {
        return standardDeviation;
    }

    public void setStandardDeviation(double standardDeviation) {
        this.standardDeviation = standardDeviation;
    }

    public LocalDateTime getSessionStartDate() {
        return sessionStartDate;
    }

    public void setSessionStartDate(LocalDateTime sessionStartDate) {
        this.sessionStartDate = sessionStartDate;
    }

    public LocalDateTime getSessionEndDate() {
        return sessionEndDate;
    }

    public void setSessionEndDate(LocalDateTime sessionEndDate) {
        this.sessionEndDate = sessionEndDate;
    }

    public Long getQualificationSession() {
        return qualificationSession;
    }

    public void setQualificationSession(Long qualificationSession) {
        this.qualificationSession = qualificationSession;
    }
}
