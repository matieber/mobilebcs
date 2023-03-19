package com.mobilebcs;

import com.mobilebcs.controller.user.UserType;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;


@ActiveProfiles("test")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
public class QualifierITCase extends AbstractITCase {


    private static final String LOCATION_CODE = "DEFAULT";


    @LocalServerPort
    private int port;

    private RestCaller restCaller;

    @Value("${images.path}")
    private String imagePath;

    @Value("${images.queue.name}")
    private String imageQueueName;

    @Autowired
    private JmsTemplate jmsTemplate;

    @Autowired
    private JdbcTemplate jdbcTemplate;
    @BeforeEach
    public void init() throws IOException {


        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
        restCaller = new RestCaller(port);
    }


    @Test
    public void testMultipleQualifiers() throws IOException, InterruptedException {


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
            Thread.sleep(1000L);
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
        UUID setCode1 = restCaller.sendImage(1, LOCATION_CODE);
        UUID setCode2 = restCaller.sendImage(2, LOCATION_CODE);


        restCaller.testNextJob(name, 1);
        restCaller.testQualify(name,setCode1,2);
        assertScore(name,setCode1,2);
        restCaller.testNextJob(name, 2);
        restCaller.testQualify(name,setCode2,3);
        assertScore(name,setCode2,3);
        restCaller.testNextJob(name, null);
        restCaller.endSession(LOCATION_CODE);


    }

    private void assertScore(String userName, UUID setCode,int score) {



        Integer integer1 = jdbcTemplate.queryForObject(
            "SELECT COUNT(qs.SCORE) from QUALIFIED_SCORE qs " +
                //"LEFT JOIN USER_QUALIFICATION_SESSION usq ON qs.USER_ID = usq.USER_ID AND qs.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                //"LEFT JOIN USER_LOCATION_QUALIFICATION_SESSION ulsq ON usq.USER_ID = usq.USER_ID AND ulsq.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                //"LEFT JOIN QUALIFICATION_SESSION qsession ON ulsq.QUALIFICATION_SESSION_ID = qsession.ID " +
                //"LEFT JOIN USER u ON u.ID = ulsq.USER_ID "+
                "LEFT JOIN IMAGE_SET_QUALIFICATION_SESSION isql ON qs.IMAGE_SET_ID = isql.IMAGE_SET_ID " +
                //"AND isql.QUALIFICATION_SESSION_ID = qsession.ID "+
                "LEFT JOIN IMAGE_SET iset ON iset.ID = isql.IMAGE_SET_ID " +
                //"WHERE u.USER_NAME = '"+userName+"' " +
                "AND iset.SET_CODE = '" + setCode.toString() + "'", Integer.class);

        Assertions.assertTrue(integer1>0);

        Integer integer = jdbcTemplate.queryForObject(
            "SELECT COUNT(qs.SCORE) from QUALIFIED_SCORE qs " +
                "LEFT JOIN USER_QUALIFICATION_SESSION usq ON qs.USER_ID = usq.USER_ID AND qs.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                //"LEFT JOIN USER_LOCATION_QUALIFICATION_SESSION ulsq ON usq.USER_ID = usq.USER_ID AND ulsq.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                //"LEFT JOIN QUALIFICATION_SESSION qsession ON ulsq.QUALIFICATION_SESSION_ID = qsession.ID " +
                "LEFT JOIN QUALIFICATION_SESSION qsession ON usq.QUALIFICATION_SESSION_ID = qsession.ID " +
                //"LEFT JOIN USER u ON u.ID = ulsq.USER_ID "+
                "LEFT JOIN USER u ON u.ID = usq.USER_ID "+
                "LEFT JOIN IMAGE_SET_QUALIFICATION_SESSION isql ON qs.IMAGE_SET_ID = isql.IMAGE_SET_ID AND isql.QUALIFICATION_SESSION_ID = qsession.ID " +
                "LEFT JOIN IMAGE_SET iset ON iset.ID = isql.IMAGE_SET_ID " +
                "WHERE u.USER_NAME = '"+userName+"' " +
                "AND iset.SET_CODE = '" + setCode.toString() + "'", Integer.class);
        Assertions.assertTrue(integer>0);

        Integer actualScore = jdbcTemplate.queryForObject(
                "SELECT qs.SCORE from QUALIFIED_SCORE qs " +
                        "LEFT JOIN USER_QUALIFICATION_SESSION usq ON qs.USER_ID = usq.USER_ID AND qs.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                        "LEFT JOIN USER_LOCATION_QUALIFICATION_SESSION ulsq ON usq.USER_ID = usq.USER_ID AND ulsq.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                        "LEFT JOIN QUALIFICATION_SESSION qsession ON ulsq.QUALIFICATION_SESSION_ID = qsession.ID " +
                        "LEFT JOIN USER u ON u.ID = ulsq.USER_ID "+
                        "LEFT JOIN IMAGE_SET_QUALIFICATION_SESSION isql ON qs.IMAGE_SET_ID = isql.IMAGE_SET_ID AND isql.QUALIFICATION_SESSION_ID = qsession.ID "+
                        "LEFT JOIN IMAGE_SET iset ON iset.ID = isql.IMAGE_SET_ID "+
                        "WHERE u.USER_NAME = '"+userName+"' AND iset.SET_CODE = '"+setCode.toString()+"'", Integer.class);
        Assertions.assertNotNull(actualScore);
        Assertions.assertEquals(score,actualScore);
    }


}
