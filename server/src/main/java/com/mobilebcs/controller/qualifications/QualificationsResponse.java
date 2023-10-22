package com.mobilebcs.controller.qualifications;

import java.util.List;

public class QualificationsResponse {

    private List<QualificationResponse> qualificationResponse;

    public QualificationsResponse(){}
    public QualificationsResponse(List<QualificationResponse> qualificationResponse) {
        this.qualificationResponse = qualificationResponse;
    }

    public List<QualificationResponse> getQualificationResponse() {
        return qualificationResponse;
    }

    public void setQualificationResponse(List<QualificationResponse> qualificationResponse) {
        this.qualificationResponse = qualificationResponse;
    }
}
