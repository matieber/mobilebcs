package com.mobilebcs.controller.qualifications;

public class QualificationResponse {

    private Long id;

    public QualificationResponse() {
    }
    public QualificationResponse(Long id) {
        this.id = id;
    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
}
