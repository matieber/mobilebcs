package com.mobilebcs.domain.qualifier;

import java.util.List;
import java.util.UUID;

public class NextCaravanMessage {

    private Integer position;
    private UUID setId;

    private String locationCode;

    private List<byte[]> images;

    private NextCaravanMessage(){}

    public NextCaravanMessage(Integer position, UUID setId, String locationCode, List<byte[]> images) {
        this.position=position;
        this.setId = setId;
        this.locationCode =locationCode;
        this.images=images;
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

    public void setLocationCode(String locationCode) {
        this.locationCode = locationCode;
    }

    public List<byte[]> getImages() {
        return images;
    }

    public void setImages(List<byte[]> images) {
        this.images = images;
    }
}
