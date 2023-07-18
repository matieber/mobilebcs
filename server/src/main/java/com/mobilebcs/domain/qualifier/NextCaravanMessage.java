package com.mobilebcs.domain.qualifier;

import java.util.List;
import java.util.UUID;

public class NextCaravanMessage {

    private String identification;
    private Integer position;
    private UUID setCode;

    private String locationCode;

    private List<byte[]> images;

    private NextCaravanMessage(){}

    public NextCaravanMessage(Integer position, UUID setCode, String locationCode, List<byte[]> images,String identification) {
        this.position=position;
        this.setCode = setCode;
        this.locationCode =locationCode;
        this.images=images;
        this.identification =identification;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public UUID getSetCode() {
        return setCode;
    }

    public void setSetCode(UUID setCode) {
        this.setCode = setCode;
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

    public String getIdentification() {
        return identification;
    }

    public void setIdentification(String identification) {
        this.identification = identification;
    }
}
