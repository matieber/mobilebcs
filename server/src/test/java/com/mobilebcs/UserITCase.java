package com.mobilebcs;

import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.controller.user.UserType;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.util.UUID;


@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class UserITCase extends AbstractITCase {

    @Autowired
    private TestRestTemplate restTemplate;


    @Test
    public void testCreateUserAndStartUserSession() {
        String userName = "user" + UUID.randomUUID();
        UserRequest userRequest = new UserRequest(userName, UserType.QUALIFIER.name());
        ResponseEntity<Void> creationResponse = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(201, creationResponse.getStatusCodeValue());

        ResponseEntity<UserResponse> startUserSessionResponse = restTemplate.exchange("/user/{username}", HttpMethod.POST, new HttpEntity<>(null, null), UserResponse.class, userName);
        Assertions.assertEquals(201, startUserSessionResponse.getStatusCodeValue());
        UserResponse userResponseBody = startUserSessionResponse.getBody();
        Assertions.assertNotNull(userResponseBody);
        Assertions.assertEquals(userName, userResponseBody.getUsername());
        Assertions.assertEquals(userRequest.getUserType(), userResponseBody.getUserType().name());

    }

    @Test
    public void testStartSessionFromInvalidUser() {
        String userName = "user" + UUID.randomUUID();

        ResponseEntity<String> startUserSessionResponse = restTemplate.exchange("/user/{username}", HttpMethod.POST, new HttpEntity<>(null, null), String.class, userName);
        Assertions.assertEquals(404, startUserSessionResponse.getStatusCodeValue());
    }

    @Test
    public void testCreateDuplicatedUser() {
        String userName = "user" + UUID.randomUUID();
        UserRequest userRequest = new UserRequest(userName, UserType.QUALIFIER.name());
        ResponseEntity<Void> response = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(201, response.getStatusCodeValue());

        response = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(400, response.getStatusCodeValue());
    }

}
