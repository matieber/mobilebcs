package com.mobilebcs.controller.user;

import com.mobilebcs.domain.exception.DuplicatedUsernameException;
import com.mobilebcs.domain.exception.InvalidRequestExeption;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.UserCreatorService;
import com.mobilebcs.domain.user.UserSessionService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.sql.SQLException;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserCreatorService userCreatorService;
    private final UserSessionService userSessionService;

    public UserController(UserCreatorService userCreatorService, UserSessionService userSessionService) {
        this.userCreatorService = userCreatorService;
        this.userSessionService = userSessionService;
    }

    @PostMapping(value = "/{name}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<UserResponse> login(@PathVariable("name") String username) throws UserNonexistentException {
        UserResponse userResponse = userSessionService.login(username);
        return ResponseEntity.status(201).body(userResponse);
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> create(@RequestBody UserRequest userRequest) throws SQLException, DuplicatedUsernameException, InvalidRequestExeption {
        userCreatorService.create(userRequest);
        return ResponseEntity.status(201).build();
    }
}
