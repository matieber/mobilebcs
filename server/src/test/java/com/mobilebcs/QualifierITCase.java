package com.mobilebcs;

import com.mobilebcs.controller.images.CaravanImage;
import com.mobilebcs.controller.images.CaravanRequest;
import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.images.ImageEncoder;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;


@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class QualifierITCase extends AbstractITCase {


    private static final String LOCATION_CODE = "DEFAULT";
    @LocalServerPort
    private Long randomServerPort;

    @Value("${activemq.brokerUrl}")
    private String brokerUrl;

    @Value("${images.queue.name}")
    private String queueName;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private JmsTemplate jmsTemplate;

    private static final String IMAGE_NAME = "primer-plano-lateral-vaca-raza-hereford";
    private static final String IMAGE_EXTENSION = "jpg";


    private String locationCode;

    @Value("${images.path}")
    private String imagePath;

    @TempDir
    private File path;

    @BeforeEach
    public void init() throws IOException {
        locationCode = LOCATION_CODE;

        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
    }

    @Test
    @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD)
    public void testMultipleQualifiers() throws IOException {


        String name1 = "qualifier1" + UUID.randomUUID();
        String name2 = "qualifier2" + UUID.randomUUID();
        String name3 = "qualifier3" + UUID.randomUUID();
        createUser(name1, UserType.QUALIFIER);
        createUser(name2, UserType.QUALIFIER);
        createUser(name3, UserType.QUALIFIER);
        long qualificationSession = joinQualificationSession(name1, null);
        joinQualificationSession(name2, qualificationSession);
        for (int position = 0; position < 10; position++) {
            sendMessage(position, LOCATION_CODE);
        }

        System.out.println("Llamada 1");
        for (int position = 0; position < 10; position++) {
            testNextJob(name1, position);
        }
        testNextJob(name1, null);


        for (int position = 0; position < 10; position++) {
            testNextJob(name2, position);
        }
        testNextJob(name2, null);


        int position10 = 10;
        joinQualificationSession(name3, qualificationSession);
        sendMessage(position10, LOCATION_CODE);
        testNextJob(name1, position10);
        testNextJob(name1, null);
        testNextJob(name2, position10);
        testNextJob(name2, null);

        testNextJob(name3, position10);
        testNextJob(name3, null);

        endSession();
    }

    private void sendMessage(int position, String locationCode) throws IOException {


        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list = new ArrayList<>();
        byte[] content = ImageEncoder.getImage(IMAGE_NAME, IMAGE_EXTENSION);
        list.add(new CaravanImage(content, IMAGE_NAME + "." + IMAGE_EXTENSION));

        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, list, setCode), Void.class);
        Assertions.assertEquals(204, response.getStatusCodeValue());


    }

    @Test
    @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD)
    public void testQualifier() throws IOException {
        String name = "qualifier1" + UUID.randomUUID();
        createUser(name, UserType.QUALIFIER);

        joinQualificationSession(name, null);
        sendMessage(1, LOCATION_CODE);
        sendMessage(2, LOCATION_CODE);


        testNextJob(name, 1);
        testNextJob(name, 2);
        testNextJob(name, null);
        endSession();


    }

    private void testNextJob(String name, Integer position) {
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


    private long joinQualificationSession(String name, Long qualificationSession) {
        ResponseEntity<UserResponse> entity;
        if (qualificationSession == null) {
            entity = restTemplate.postForEntity("/location/" + LOCATION_CODE + "/user/" + name + "/qualificationSession", null, UserResponse.class);
        } else {
            entity = restTemplate.exchange("/location/" + LOCATION_CODE + "/user/" + name + "/qualificationSession/" + qualificationSession, HttpMethod.PUT, new HttpEntity<>(null, null), UserResponse.class);
        }
        Assertions.assertEquals(200, entity.getStatusCodeValue());
        UserResponse user = entity.getBody();
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name, user.getUsername());
        return user.getQualificationSession();
    }

    private void endSession() {
        ResponseEntity<Void> endResponse = restTemplate.exchange("/location/{locationCode}/qualificationSession", HttpMethod.DELETE, new HttpEntity<>(null, null), Void.class, LOCATION_CODE);
        Assertions.assertEquals(204, endResponse.getStatusCodeValue());
    }

    private void createUser(String userName, UserType qualifier) {
        UserRequest userRequest = new UserRequest(userName, qualifier.name());
        ResponseEntity<Void> creationResponse = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(201, creationResponse.getStatusCodeValue());
    }


}
