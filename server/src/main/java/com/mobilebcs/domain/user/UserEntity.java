package com.mobilebcs.domain.user;

import java.util.Objects;

public class UserEntity {

    private int id;

    private String userName;
    private String type;

    public UserEntity(){}

    public UserEntity(String userName, String type) {
        this.userName = userName;
        this.type = type;
    }
    public UserEntity(int id,String userName, String type) {
        this.id = id;
        this.userName = userName;
        this.type = type;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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
        UserEntity that = (UserEntity) o;
        return id == that.id && Objects.equals(userName, that.userName) && Objects.equals(type, that.type);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, userName, type);
    }
}
