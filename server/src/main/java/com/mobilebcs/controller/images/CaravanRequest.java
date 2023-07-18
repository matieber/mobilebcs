package com.mobilebcs.controller.images;

import java.util.List;
import java.util.UUID;

public class CaravanRequest {

    private Integer position;

    private String identification;
    private List<CaravanImage> images;

    private UUID setId;


    public CaravanRequest(){}

    public CaravanRequest(Integer position, String identification, List<CaravanImage> images, UUID setId) {
        this.position=position;
        this.identification = identification;
        this.images = images;
        this.setId = setId;
    }

    public List<CaravanImage> getImages() {
        return images;
    }

    public void setImages(List<CaravanImage> images) {
        this.images = images;
    }

    public UUID getSetId() {
        return setId;
    }

    public void setSetId(UUID setId) {
        this.setId = setId;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public String getIdentification() {
        return identification;
    }

    public void setIdentification(String identification) {
        this.identification = identification;
    }
}
