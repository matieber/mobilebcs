package com.mobilebcs.controller.prediction;


public class PredictionCriteria {

    private String location;

    private SearchType searchType;


    public PredictionCriteria(){}
    public PredictionCriteria( String location) {
        this.location = location;
    }


    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }


    public SearchType getSearchType() {
        return searchType;
    }

    public void setSearchType(SearchType searchType) {
        this.searchType = searchType;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("PredictionCriteria{");
        sb.append("location='").append(location).append('\'');
        sb.append(", searchType=").append(searchType);
        sb.append('}');
        return sb.toString();
    }
}
