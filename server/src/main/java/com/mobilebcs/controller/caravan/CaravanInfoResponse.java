package com.mobilebcs.controller.caravan;

import java.util.List;
import java.util.StringJoiner;

public class CaravanInfoResponse {

    private List<CaravanQualificationResponse> list;

    public CaravanInfoResponse(){}
    public CaravanInfoResponse(List<CaravanQualificationResponse> list) {
        this.list = list;
    }

    public List<CaravanQualificationResponse> getList() {
        return list;
    }

    public void setList(List<CaravanQualificationResponse> list) {
        this.list = list;
    }

    @Override
    public String toString() {
        return new StringJoiner(", ", CaravanInfoResponse.class.getSimpleName() + "[", "]")
                .add("list=" + list)
                .toString();
    }
}
