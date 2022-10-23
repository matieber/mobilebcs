package com.mobilebcs.controller.user;

public class UserRequest {

    public String userName;
    private String userType;

    public UserRequest(){}

    public UserRequest(String userName, String userType) {
        this.userName = userName;
        this.userType = userType;
    }

    public String getUsername() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }
}
