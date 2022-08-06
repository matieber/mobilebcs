package com.mobilebcs.controller;

import com.mobilebcs.domain.UserNonexistentException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class DefaultExceptionHandler {


    @ExceptionHandler(UserNonexistentException.class)
    public ResponseEntity<String> notFound(UserNonexistentException exception){
        return ResponseEntity.status(404).body(exception.getMessage());
    }
    @ExceptionHandler({Exception.class})
    public ResponseEntity<String> unknownError(Exception error) {

        return ResponseEntity.status(500).body(error.getMessage());
    }
}
