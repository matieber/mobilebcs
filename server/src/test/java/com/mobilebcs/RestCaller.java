package com.mobilebcs;

import com.mobilebcs.controller.images.CaravanImage;
import com.mobilebcs.controller.images.CaravanRequest;
import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.images.ImageEncoder;
import org.junit.jupiter.api.Assertions;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;


public class RestCaller {

    private static final String IMAGE_NAME = "primer-plano-lateral-vaca-raza-hereford";
    private static final String IMAGE_EXTENSION = "jpg";


    private RestTemplate restTemplate;

    public RestCaller(int port) {
        restTemplate = new RestTemplateBuilder().rootUri("http://localhost:" + port).build();
    }

    void sendImage(int position, String locationCode) throws IOException {

        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list = new ArrayList<>();
        byte[] content = ImageEncoder.getImage(IMAGE_NAME, IMAGE_EXTENSION);
        list.add(new CaravanImage(content, IMAGE_NAME + "." + IMAGE_EXTENSION));

        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, list, setCode), Void.class);
        Assertions.assertEquals(204, response.getStatusCodeValue());


    }

    void testNextJob(String name, Integer position) {
        ResponseEntity<NextCaravanMessage> entity = restTemplate.getForEntity("/qualifier/" + name + "/next-animal", NextCaravanMessage.class);


        if (position != null) {
            Assertions.assertEquals(200, entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNotNull(nextCaravanMessage);
            Assertions.assertEquals(position, nextCaravanMessage.getPosition());
        } else {
            Assertions.assertEquals(204, entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNull(nextCaravanMessage);
        }
    }

    long joinQualificationSession(String name, Long qualificationSession, String locationCode) {
        ResponseEntity<UserResponse> entity;
        if (qualificationSession == null) {
            entity = restTemplate.postForEntity("/location/" + locationCode + "/user/" + name + "/qualificationSession", null, UserResponse.class);
        } else {
            entity = restTemplate.exchange("/location/" + locationCode + "/user/" + name + "/qualificationSession/" + qualificationSession, HttpMethod.PUT, new HttpEntity<>(null, null), UserResponse.class);
        }
        Assertions.assertEquals(200, entity.getStatusCodeValue());
        UserResponse user = entity.getBody();
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name, user.getUsername());
        return user.getQualificationSession();
    }

    void endSession(String locationCode) {
        ResponseEntity<Void> endResponse = restTemplate.exchange("/location/{locationCode}/qualificationSession", HttpMethod.DELETE, new HttpEntity<>(null, null), Void.class, locationCode);
        Assertions.assertEquals(204, endResponse.getStatusCodeValue());
    }

    void createUser(String userName, UserType qualifier) {
        UserRequest userRequest = new UserRequest(userName, qualifier.name());
        ResponseEntity<Void> creationResponse = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(201, creationResponse.getStatusCodeValue());
    }
}