package com.mobilebcs.domain.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

public class UserNonexistentException extends Exception {

    public UserNonexistentException(String message) {
        super(message);
    }
}
