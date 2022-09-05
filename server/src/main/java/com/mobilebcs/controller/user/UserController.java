package com.mobilebcs.controller.user;

import com.mobilebcs.domain.InvalidOperationException;
import com.mobilebcs.domain.UserCreatorService;
import com.mobilebcs.domain.UserStarterService;
import com.mobilebcs.domain.UserNonexistentException;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.jms.JMSException;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserStarterService startUserSession;
    private final UserCreatorService userCreatorService;

    public UserController(UserStarterService startUserSession, UserCreatorService userCreatorService) {
        this.startUserSession = startUserSession;
        this.userCreatorService = userCreatorService;
    }

    @GetMapping(value = "/{name}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<User> startUserSession(@PathVariable("name") String name) throws UserNonexistentException, InvalidOperationException, JMSException {
        User user= startUserSession.startUserSession(name);
        return ResponseEntity.ok(user);
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> create(@RequestBody User user){
        userCreatorService.create(user);
        return ResponseEntity.status(201).build();
    }
}
