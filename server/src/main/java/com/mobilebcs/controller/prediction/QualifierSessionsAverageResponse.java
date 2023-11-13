package com.mobilebcs.controller.prediction;

import java.util.List;

public class QualifierSessionsAverageResponse {

    private List<QualifierSessionAverageResponse> values;

    private QualifierSessionsAverageResponse(){}

    public QualifierSessionsAverageResponse(List<QualifierSessionAverageResponse> values) {
        this.values = values;
    }

    public List<QualifierSessionAverageResponse> getValues() {
        return values;
    }

    public void setValues(List<QualifierSessionAverageResponse> values) {
        this.values = values;
    }


}
