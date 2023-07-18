package com.mobilebcs.controller.prediction;

import java.util.List;

public class QualifierSessionsPredictionResponse {

    private List<QualifierSessionPredictionResponse> values;

    private QualifierSessionsPredictionResponse(){}

    public QualifierSessionsPredictionResponse(List<QualifierSessionPredictionResponse> values) {
        this.values = values;
    }

    public List<QualifierSessionPredictionResponse> getValues() {
        return values;
    }

    public void setValues(List<QualifierSessionPredictionResponse> values) {
        this.values = values;
    }


}
