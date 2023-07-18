package com.mobilebcs.controller.prediction;

public class ScoreResponse {

    private Double value;
    public ScoreResponse(){}
    public ScoreResponse(Double value) {
        this.value = value;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("ScoreResponse{");
        sb.append("value=").append(value);
        sb.append('}');
        return sb.toString();
    }
}
