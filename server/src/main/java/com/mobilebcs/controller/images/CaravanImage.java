package com.mobilebcs.controller.images;

public class CaravanImage {

    private byte[] content;
    private String fileName;

    public CaravanImage(){}
    public CaravanImage(byte[] content, String fileName) {
        this.content = content;
        this.fileName = fileName;
    }

    public byte[] getContent() {
        return content;
    }

    public void setContent(byte[] content) {
        this.content = content;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
}
