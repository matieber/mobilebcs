package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserType;

import java.util.Objects;

public class User {

    private String username;
    private UserType userType;

    public User(){}

    public User(String username, UserType userType) {
        this.username = username;
        this.userType = userType;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return Objects.equals(username, user.username) && userType == user.userType;
    }

    @Override
    public int hashCode() {
        return Objects.hash(username, userType);
    }
}
