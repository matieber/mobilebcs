package com.mobilebcs;

import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.restart.ApplicationRestarter;
import org.apache.commons.io.FileUtils;
import org.junit.AfterClass;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestClassOrder;
import org.springframework.test.annotation.DirtiesContext;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.nio.file.Paths;
import java.util.UUID;


@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
public class QualificationWithImageAfterRestartITCase {


    private static final String LOCATION_CODE = "DEFAULT";
    private int port;

    private RestCaller restCaller;


    @BeforeEach
    public void init() throws IOException {

        port = getOpenPort();
        FileUtils.deleteDirectory(new File(Paths.get(ApplicationRestarter.getImagePath()).toString()));
        restCaller = new RestCaller(port);
    }

    private static int getOpenPort() throws IOException {
        ServerSocket s = new ServerSocket(0);
        int port = s.getLocalPort();
        s.close();
        return port;
    }


    @Test
    public void testQualifierWithRestart() throws IOException, InterruptedException {
        ApplicationRestarter.start(port);
        String name = UUID.randomUUID().toString();
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
