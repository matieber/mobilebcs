package com.mobilebcs;

import com.mobilebcs.controller.user.UserType;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;


@ActiveProfiles("test")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class QualifierITCase extends AbstractITCase {


    private static final String LOCATION_CODE = "DEFAULT";

    @LocalServerPort
    private int port;

    private RestCaller restCaller;

    @Value("${images.path}")
    private String imagePath;

    @BeforeEach
    public void init() throws IOException {


        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
        restCaller = new RestCaller(port);
    }

    @Test
    public void testMultipleQualifiers() throws IOException {


        String name1 = "qualifier1" + UUID.randomUUID();
        String name2 = "qualifier2" + UUID.randomUUID();
        String name3 = "qualifier3" + UUID.randomUUID();
        restCaller.createUser(name1, UserType.QUALIFIER);
        restCaller.createUser(name2, UserType.QUALIFIER);
        restCaller.createUser(name3, UserType.QUALIFIER);
        long qualificationSession = restCaller.joinQualificationSession(name1, null, LOCATION_CODE);
        restCaller.joinQualificationSession(name2, qualificationSession, LOCATION_CODE);
        for (int position = 0; position < 10; position++) {
            restCaller.sendImage(position, LOCATION_CODE);
        }

        System.out.println("Llamada 1");
        for (int position = 0; position < 10; position++) {
            restCaller.testNextJob(name1, position);
        }
        restCaller.testNextJob(name1, null);


        for (int position = 0; position < 10; position++) {
            restCaller.testNextJob(name2, position);
        }
        restCaller.testNextJob(name2, null);


        int position10 = 10;
        restCaller.joinQualificationSession(name3, qualificationSession, LOCATION_CODE);
        restCaller.sendImage(position10, LOCATION_CODE);
        restCaller.testNextJob(name1, position10);
        restCaller.testNextJob(name1, null);
        restCaller.testNextJob(name2, position10);
        restCaller.testNextJob(name2, null);

        restCaller.testNextJob(name3, position10);
        restCaller.testNextJob(name3, null);

        restCaller.endSession(LOCATION_CODE);
    }

    @Test
    public void testQualifier() throws IOException {
        String name = "qualifier1" + UUID.randomUUID();
        restCaller.createUser(name, UserType.QUALIFIER);

        restCaller.joinQualificationSession(name, null, LOCATION_CODE);
        restCaller.sendImage(1, LOCATION_CODE);
        restCaller.sendImage(2, LOCATION_CODE);


        restCaller.testNextJob(name, 1);
        restCaller.testNextJob(name, 2);
        restCaller.testNextJob(name, null);
        restCaller.endSession(LOCATION_CODE);


    }


}
