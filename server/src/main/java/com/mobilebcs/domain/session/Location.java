package com.mobilebcs.domain.session;

public class Location {

    private final String code;
    private final String name;

    public Location(String code, String name) {
        this.code = code;
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }
}
