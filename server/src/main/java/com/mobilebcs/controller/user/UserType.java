package com.mobilebcs.controller.user;

import java.util.Arrays;

public enum UserType {

    QUALIFIER,
    VIEWER;

    public static UserType valueFrom(String userType) {
        return Arrays.stream(values()).filter(value->value.name().equals(userType)).findAny().orElse(null);
    }
}
