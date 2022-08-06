package com.mobilebcs.domain;

public class NextCaravanMessage {

    private Integer position;

    private NextCaravanMessage(){}

    public NextCaravanMessage(Integer position) {
        this.position = position;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }
}
