package com.mobilebcs.controller;

import com.mobilebcs.domain.exception.DuplicatedSessionForLocationException;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.exception.DuplicatedUsernameException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class DefaultExceptionHandler {

    private static final Logger LOG = LoggerFactory.getLogger(DefaultExceptionHandler.class);
    @ExceptionHandler(UserNonexistentException.class)
    public ResponseEntity<String> notFound(UserNonexistentException exception){
        LOG.error(exception.toString(),exception);
        return ResponseEntity.status(404).body(exception.getMessage());
    }

    @ExceptionHandler(InvalidOperationException.class)
    public ResponseEntity<String> notFound(InvalidOperationException exception){
        LOG.error(exception.toString(),exception);
        return ResponseEntity.status(400).body(exception.getMessage());
    }

    @ExceptionHandler(DuplicatedSessionForLocationException.class)
    public ResponseEntity<String> duplicatedSessionForLocationException(DuplicatedSessionForLocationException exception){
        LOG.error(exception.toString(),exception);
        return ResponseEntity.status(400).body(exception.getMessage());
    }

    @ExceptionHandler(InvalidLocalizationException.class)
    public ResponseEntity<String> invalidLocalization(InvalidLocalizationException exception){
        LOG.error(exception.toString(),exception);
        return ResponseEntity.status(404).body(exception.getMessage());
    }

    @ExceptionHandler(DuplicatedUsernameException.class)
    public ResponseEntity<String> invalidUserName(DuplicatedUsernameException exception){
        LOG.error(exception.toString(),exception);
        return ResponseEntity.status(400).body(exception.getMessage());
    }

    @ExceptionHandler({Exception.class})
    public ResponseEntity<String> unknownError(Exception exception) {
        LOG.error(exception.toString(),exception);
        return ResponseEntity.status(500).body(exception.getMessage());
    }
}
