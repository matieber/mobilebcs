package com.mobilebcs;

import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.controller.user.UserType;
import org.apache.commons.io.FileUtils;
import org.checkerframework.checker.units.qual.A;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.test.context.ActiveProfiles;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNotNull;

@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class QualificationSessionITCase extends AbstractITCase {

    private static final String LOCATION_CODE = "DEFAULT";
    private static final String INVALID_LOCATION_CODE = "INVALID";
    @Value("${images.path}")
    private String imagePath;

    @LocalServerPort
    private Long randomServerPort;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private NamedParameterJdbcTemplate jdbcTemplate;

    private SimpMessagingTemplate simpMessagingTemplate;

    @BeforeEach
    public void init() throws IOException {
        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
    }

    @Test
    public void testCreateNewQualificationSession() throws IOException {

        String userName = "user" + UUID.randomUUID();

        createUser(userName, UserType.QUALIFIER);

        long qualificationSessionId = createNewSession(userName, LOCATION_CODE);

        endSession(qualificationSessionId);
    }

    @Test
    public void testCreateNewQualificationSessionWithViewerUser() throws IOException {

        String userName = "user" + UUID.randomUUID();

        createUser(userName, UserType.VIEWER);

        ResponseEntity<String> response = restTemplate.postForEntity("/location/{locationCode}/user/{name}/qualificationSession", null, String.class, LOCATION_CODE, userName);

        Assertions.assertEquals(400, response.getStatusCodeValue());


    }

    @Test
    public void testCreateNewQualificationSessionInALocationWithAExistingLocation() throws IOException {

        String userName = "user" + UUID.randomUUID();

        createUser(userName, UserType.QUALIFIER);

        long qualificationSessionId = createNewSession(userName, LOCATION_CODE);

        ResponseEntity<String> duplicatedSessionResponse = restTemplate.postForEntity("/location/{locationCode}/user/{name}/qualificationSession", null, String.class, LOCATION_CODE, userName);
        Assertions.assertEquals(400, duplicatedSessionResponse.getStatusCodeValue());

        endSession(qualificationSessionId);
    }

    @Test
    public void testCreateQualificationSessionWithUnknownLocation() throws IOException {

        String userName = "user" + UUID.randomUUID();

        createUser(userName, UserType.QUALIFIER);

        ResponseEntity<String> response = restTemplate.postForEntity("/location/{locationCode}/user/{name}/qualificationSession", null, String.class, userName, INVALID_LOCATION_CODE);
        Assertions.assertEquals(404, response.getStatusCodeValue());

    }

    @Test
    public void testCreateQualificationSessionWithUnknownUser() throws IOException {

        String userName = "user" + UUID.randomUUID();


        ResponseEntity<String> response = restTemplate.postForEntity("/location/{locationCode}/user/{name}/qualificationSession", null, String.class, LOCATION_CODE, userName);
        Assertions.assertEquals(404, response.getStatusCodeValue());

    }

    @Test
    public void testCreateNewQualificationSessionAndEndingItTwice() throws IOException {

        String userName = "user" + UUID.randomUUID();

        createUser(userName, UserType.QUALIFIER);

        long qualificationSessionId = createNewSession(userName, LOCATION_CODE);

        endSessionTwice(qualificationSessionId);

    }

    @Test
    public void testJoinToAQualificationSession() {

        String userName = "user" + UUID.randomUUID();

        createUser(userName, UserType.QUALIFIER);

        String userName2 = "user" + UUID.randomUUID();

        createUser(userName2, UserType.QUALIFIER);

        long qualificationSessionId = createNewSession(userName, LOCATION_CODE);

        joinSession(userName2, qualificationSessionId);

        endSession(qualificationSessionId);
    }

    private void endSession(long qualificationSessionId) {
        ResponseEntity<Void> endResponse = restTemplate.exchange("/location/{locationCode}/qualificationSession", HttpMethod.DELETE, new HttpEntity<>(null, null), Void.class, LOCATION_CODE);
        Assertions.assertEquals(204, endResponse.getStatusCodeValue());
        List<UserQualificationSessionEntity> userQualificationSessionEntities = getUserQualificationSessionEntities(LOCATION_CODE, qualificationSessionId);
        Assertions.assertNotNull(userQualificationSessionEntities);
        Assertions.assertEquals(0, userQualificationSessionEntities.size());
    }

    private void endSessionTwice(long qualificationSessionId) {
        ResponseEntity<Void> endResponse = restTemplate.exchange("/location/{locationCode}/qualificationSession", HttpMethod.DELETE, new HttpEntity<>(null, null), Void.class, LOCATION_CODE);
        Assertions.assertEquals(204, endResponse.getStatusCodeValue());
        List<UserQualificationSessionEntity> userQualificationSessionEntities = getUserQualificationSessionEntities(LOCATION_CODE, qualificationSessionId);
        Assertions.assertNotNull(userQualificationSessionEntities);
        Assertions.assertEquals(0, userQualificationSessionEntities.size());

        ResponseEntity<String> failEndingResponse = restTemplate.exchange("/location/{locationCode}/qualificationSession", HttpMethod.DELETE, new HttpEntity<>(null, null), String.class, LOCATION_CODE);
        Assertions.assertEquals(400, failEndingResponse.getStatusCodeValue());
    }

    private void joinSession(String userName, long qualificationSession) {
        ResponseEntity<UserResponse> response = restTemplate.exchange("/location/{locationCode}/user/{name}/qualificationSession/{qualificationSession}", HttpMethod.PUT, null, UserResponse.class, LOCATION_CODE, userName, qualificationSession);
        Assertions.assertEquals(200, response.getStatusCodeValue());
        UserResponse userResponse = response.getBody();
        assertNotNull(userResponse);
        long actualQualificationSession = userResponse.getQualificationSession();
        Assertions.assertTrue(actualQualificationSession > 0);
    }

    private long createNewSession(String userName, String locationCode) {
        ResponseEntity<UserResponse> response = restTemplate.postForEntity("/location/{locationCode}/user/{name}/qualificationSession", null, UserResponse.class, locationCode, userName);
        Assertions.assertEquals(200, response.getStatusCodeValue());
        UserResponse userResponse = response.getBody();
        assertNotNull(userResponse);
        long actualQualificationSession = userResponse.getQualificationSession();
        Assertions.assertTrue(actualQualificationSession > 0);


        List<UserQualificationSessionEntity> userQualificationSessionEntities = getUserQualificationSessionEntities(locationCode, actualQualificationSession);

        Assertions.assertEquals(1, userQualificationSessionEntities.size());
        Assertions.assertEquals(userName, userQualificationSessionEntities.get(0).getUserName());
        Assertions.assertEquals(actualQualificationSession, userQualificationSessionEntities.get(0).getQualificationSessionId());
        return actualQualificationSession;
    }

    private List<UserQualificationSessionEntity> getUserQualificationSessionEntities(String locationCode, long actualQualificationSession) {
        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("qualificationSession", actualQualificationSession);
        paramMap.put("locationCode", locationCode);
        List<UserQualificationSessionEntity> userQualificationSessionEntities = jdbcTemplate.query(
                "SELECT u.USER_NAME, uqs.QUALIFICATION_SESSION_ID FROM USER_QUALIFICATION_SESSION uqs " +
                        "INNER JOIN USER_LOCATION_QUALIFICATION_SESSION ulqs ON uqs.QUALIFICATION_SESSION_ID = ulqs.QUALIFICATION_SESSION_ID " +
                        "INNER JOIN LOCATION_QUALIFICATION_SESSION lqs ON lqs.QUALIFICATION_SESSION_ID = uqs.QUALIFICATION_SESSION_ID " +
                        "INNER JOIN LOCATION l ON l.ID = lqs.LOCATION_ID " +
                        "INNER JOIN QUALIFICATION_SESSION qs ON qs.ID = ulqs.QUALIFICATION_SESSION_ID " +
                        "INNER JOIN `USER` u ON u.ID = uqs.USER_ID " +
                        "WHERE uqs.QUALIFICATION_SESSION_ID=:qualificationSession AND l.CODE =:locationCode", paramMap, new BeanPropertyRowMapper<>(UserQualificationSessionEntity.class));
        return userQualificationSessionEntities;
    }

    private void createUser(String userName, UserType qualifier) {
        UserRequest userRequest = new UserRequest(userName, qualifier.name());
        ResponseEntity<Void> creationResponse = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(201, creationResponse.getStatusCodeValue());
    }

}
