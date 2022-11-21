package com.mobilebcs;

import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.restart.ApplicationRestarter;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;


public class TestAfterRestartITCase {


    private static final String LOCATION_CODE = "DEFAULT";


    private RestCaller restCaller;


    private ApplicationRestarter applicationRestarter;


    @BeforeAll
    public static void start() {

        ApplicationRestarter.start();
    }

    @BeforeEach
    public void init() throws IOException {


        FileUtils.deleteDirectory(new File(Paths.get(ApplicationRestarter.getImagePath()).toString()));
        restCaller = new RestCaller(8080);
    }


    @Test
    public void testQualifierWithRestart() throws IOException, InterruptedException {
        String name = "qualifier1" + UUID.randomUUID();
        restCaller.createUser(name, UserType.QUALIFIER);


        restCaller.joinQualificationSession(name, null, LOCATION_CODE);
        ApplicationRestarter.restart();
        restCaller.sendImage(1, LOCATION_CODE);
        restCaller.sendImage(2, LOCATION_CODE);
        ApplicationRestarter.restart();
        restCaller.testNextJob(name, 1);
        restCaller.testNextJob(name, 2);


        ApplicationRestarter.restart();
        restCaller.testNextJob(name, null);
        ApplicationRestarter.restart();
        restCaller.endSession(LOCATION_CODE);
    }


}
