package com.mobilebcs.images;

public class ImageEntity {


    private String path;
    private String identification;


    public ImageEntity(String path, String identification) {
        this.path = path;
        this.identification = identification;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getIdentification() {
        return identification;
    }

    public void setIdentification(String identification) {
        this.identification = identification;
    }
}
