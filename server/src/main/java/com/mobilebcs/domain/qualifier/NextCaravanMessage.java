package com.mobilebcs.domain.qualifier;

import java.util.UUID;

public class NextCaravanMessage {

    private Integer position;
    private UUID setId;

    private String locationCode;

    private NextCaravanMessage(){}

    public NextCaravanMessage(Integer position, UUID setId, String locationCode) {
        this.position=position;
        this.setId = setId;
        this.locationCode =locationCode;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public UUID getSetId() {
        return setId;
    }

    public void setSetId(UUID setId) {
        this.setId = setId;
    }


    public String getLocationCode() {
        return locationCode;
    }
}
