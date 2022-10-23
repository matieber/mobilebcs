package com.mobilebcs.controller.images;

import java.util.List;
import java.util.UUID;

public class CaravanRequest {

    private Integer position;
    private List<CaravanImage> images;

    private UUID setId;


    public CaravanRequest(){}

    public CaravanRequest(Integer position,List<CaravanImage> images, UUID setId) {
        this.position=position;
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
}
