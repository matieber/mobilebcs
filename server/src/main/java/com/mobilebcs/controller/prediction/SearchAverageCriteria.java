package com.mobilebcs.controller.prediction;


public class SearchAverageCriteria {

    private String location;

    private int amount;


    public SearchAverageCriteria(){}
    public SearchAverageCriteria(String location) {
        this.location = location;
    }


    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }


    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("PredictionCriteria{");
        sb.append("location='").append(location).append('\'');
        sb.append(", amount=").append(amount);
        sb.append('}');
        return sb.toString();
    }
}
