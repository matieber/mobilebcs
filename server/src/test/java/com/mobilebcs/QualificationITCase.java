package com.mobilebcs;

import com.mobilebcs.controller.qualifications.QualificationsResponse;
import com.mobilebcs.controller.user.UserType;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

@ActiveProfiles("test")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
public class QualificationITCase extends AbstractITCase {

    public static final String DEFAULT = "DEFAULT";
    public static final String LOCALIZATION_2 = "LOCALIZATION2";
    private RestCaller restCaller;
    private Random randomScore;

    @LocalServerPort
    private int port;

    @BeforeEach
    public void init() throws IOException {
        restCaller = new RestCaller(port);
    }

    @Test
    public void testQualifications(){
        String name1 = UUID.randomUUID().toString();
        restCaller.createUser(name1, UserType.QUALIFIER);
        String name2 = UUID.randomUUID().toString();
        restCaller.createUser(name2, UserType.QUALIFIER);

        QualificationsResponse defaultBeforeQualifications = restCaller.getQualifications(DEFAULT);
        QualificationsResponse localization2BeforeQualifications = restCaller.getQualifications(LOCALIZATION_2);

        int max = 3;
        for(int i = 0; i< max; i++) {
            restCaller.joinQualificationSession(name1, null, DEFAULT);
            restCaller.joinQualificationSession(name2, null, LOCALIZATION_2);
            restCaller.endSession(DEFAULT);
            restCaller.endSession(LOCALIZATION_2);
        }

        QualificationsResponse defaultAfterQualifications = restCaller.getQualifications(DEFAULT);
        Assertions.assertEquals(getSize(defaultBeforeQualifications)+ max, getSize(defaultAfterQualifications));

        QualificationsResponse localization2AfterQualifications = restCaller.getQualifications(LOCALIZATION_2);
        Assertions.assertEquals(getSize(localization2BeforeQualifications)+ max, getSize(localization2AfterQualifications));

    }

    private static int getSize(QualificationsResponse beforeQualifications) {
        return Optional.ofNullable(beforeQualifications).map(QualificationsResponse::getQualificationResponse).map(List::size).orElse(0);
    }
}
