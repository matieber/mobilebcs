package com.mobilebcs.domain.user;

import java.util.Objects;

public class UserEntity {

    private String userName;
    private String type;

    public UserEntity(){}

    public UserEntity(String userName, String type) {
        this.userName = userName;
        this.type = type;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserEntity user = (UserEntity) o;
        return Objects.equals(userName, user.userName) && type == user.type;
    }

    @Override
    public int hashCode() {
        return Objects.hash(userName, type);
    }
}
