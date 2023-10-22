package com.mobilebcs.controller.prediction;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class QualifierSessionPredictionResponse {


    private List<ScoreResponse> scores;
    private LocalDateTime sessionStartDate;
    private LocalDateTime sessionEndDate;
    private Long qualificationSession;
    private Integer caravanSize;

    public QualifierSessionPredictionResponse(){}

    public QualifierSessionPredictionResponse(List<ScoreResponse> scores, LocalDateTime sessionStartDate, LocalDateTime sessionEndDate, Long qualificationSession, Integer caravanSize) {
        this.scores = scores;
        this.sessionStartDate = sessionStartDate;
        this.sessionEndDate = sessionEndDate;
        this.qualificationSession = qualificationSession;
        this.caravanSize=caravanSize;
    }


    public static QualifierSessionPredictionResponse create(List<Double> scores, LocalDateTime endDate, LocalDateTime startDate, Long qualificationSessionId, Integer caravanSize) {
        List<ScoreResponse> scoreResponse = scores.stream().map(ScoreResponse::new).collect(Collectors.toList());
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = new QualifierSessionPredictionResponse();
        qualifierSessionPredictionResponse.setScores(scoreResponse);
        qualifierSessionPredictionResponse.setSessionEndDate(endDate);
        qualifierSessionPredictionResponse.setQualificationSession(qualificationSessionId);
        qualifierSessionPredictionResponse.setCaravanSize(caravanSize);
        qualifierSessionPredictionResponse.setSessionStartDate(startDate);
        return qualifierSessionPredictionResponse;
    }

    public List<ScoreResponse> getScores() {
        return scores;
    }

    public void setScores(List<ScoreResponse> scores) {
        this.scores = scores;
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

    public Integer getCaravanSize() {
        return caravanSize;
    }

    public void setCaravanSize(Integer caravanSize) {
        this.caravanSize = caravanSize;
    }


    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("QualifierSessionPredictionResponse{");
        sb.append("score=").append(scores);
        sb.append(", sessionStartDate=").append(sessionStartDate);
        sb.append(", sessionEndDate=").append(sessionEndDate);
        sb.append(", qualificationSession=").append(qualificationSession);
        sb.append(", caravanSize=").append(caravanSize);
        sb.append('}');
        return sb.toString();
    }
}
