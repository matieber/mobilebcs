package com.mobilebcs.controller.user;


public class UserResponse {

    private String username;
    private UserType userType;

    private long qualificationSession;

    public UserResponse(){}

    public UserResponse(String username, UserType userType, long qualificationSession) {
        this.username = username;
        this.userType = userType;
        this.qualificationSession = qualificationSession;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public long getQualificationSession() {
        return qualificationSession;
    }

    public void setQualificationSession(long qualificationSession) {
        this.qualificationSession = qualificationSession;
    }
}
