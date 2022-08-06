package com.mobilebcs.controller.user;

public class User {

    private  String calificatorUser;

    public User(){}
    public User(String calificatorUser) {
        this.calificatorUser = calificatorUser;
    }

    public void setCalificatorUser(String calificatorUser) {
        this.calificatorUser = calificatorUser;
    }

    public String getCalificatorUser() {
        return calificatorUser;
    }
}
