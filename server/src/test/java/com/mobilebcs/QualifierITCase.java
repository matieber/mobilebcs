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
import java.util.*;
import org.testcontainers.shaded.org.apache.commons.lang.RandomStringUtils;


@ActiveProfiles("test")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
public class QualifierITCase extends AbstractITCase {

    private static final String LOCATION_CODE = "DEFAULT";


    @LocalServerPort
    private int port;
    @Value("${images.path}")
    private String imagePath;
    @Autowired
    private JdbcTemplate jdbcTemplate;
    private RestCaller restCaller;
    private Random randomScore;

    @BeforeEach
    public void init() throws IOException {
        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
        restCaller = new RestCaller(port);
        randomScore = new Random();
    }


    @Test
    public void testMultipleQualifiers() throws IOException, InterruptedException {


        String name1 = "qualifier1" + UUID.randomUUID();
        String name2 = "qualifier2" + UUID.randomUUID();
        String name3 = "qualifier3" + UUID.randomUUID();
        createQualifiers(name1, name2, name3);

        long qualificationSession = createQualification(name1, name2);

        int amountOfImages = 10;
        ImageIdentification imageIdentification = sendImages(amountOfImages);

        qualifyImages(amountOfImages, name1, imageIdentification, qualificationSession);
        qualifyImages(amountOfImages, name2, imageIdentification, qualificationSession);

        int nextImagePosition = 10;
        joinExistingQualification(name3, qualificationSession);

        String identification10 = RandomStringUtils.randomAlphanumeric(6).toUpperCase();
        UUID uuid = restCaller.sendImage(nextImagePosition, LOCATION_CODE, identification10);
        qualifyImage(name1, nextImagePosition, identification10, uuid, qualificationSession);
        qualifyImage(name2, nextImagePosition, identification10, uuid, qualificationSession);
        qualifyImage(name3, nextImagePosition, identification10, uuid, qualificationSession);

        restCaller.endSession(LOCATION_CODE);
    }

    private void joinExistingQualification(String name3, long qualificationSession) {
        restCaller.joinQualificationSession(name3, qualificationSession, LOCATION_CODE);
        restCaller.testNextJob(name3, null, null);
    }

    @Test
    public void testQualifier() throws IOException {
        String name = "qualifier1" + UUID.randomUUID();
        restCaller.createUser(name, UserType.QUALIFIER);

        long qualificationSession = restCaller.joinQualificationSession(name, null, LOCATION_CODE);
        String identification1 = RandomStringUtils.randomAlphanumeric(6).toUpperCase();
        UUID setCode1 = restCaller.sendImage(1, LOCATION_CODE, identification1);
        String identification2 = RandomStringUtils.randomAlphanumeric(6).toUpperCase();
        UUID setCode2 = restCaller.sendImage(2, LOCATION_CODE, identification2);


        restCaller.testNextJob(name, 1, identification1);
        restCaller.testQualify(name,setCode1,2);
        assertScore(name,setCode1,2, qualificationSession);
        restCaller.testNextJob(name, 2, identification2);
        restCaller.testQualify(name,setCode2,3);
        assertScore(name,setCode2,3, qualificationSession);
        restCaller.testNextJob(name, null, null);
        restCaller.endSession(LOCATION_CODE);


    }

    private void qualifyImage(String name, int nextImagePosition, String identification, UUID uuid, long qualificationSession) {
        restCaller.testNextJob(name, nextImagePosition, identification);
        int score = createScore();
        restCaller.testQualify(name, uuid,score);
        assertScore(name, uuid,score, qualificationSession);
        restCaller.testNextJob(name, null, null);
    }

    private void qualifyImages(int amountOfImages, String name, ImageIdentification imageIdentification, long qualificationSession) {
        for (int position = 0; position < amountOfImages; position++) {
            restCaller.testNextJob(name, position, imageIdentification.identifications.get(position));
            int score = createScore();
            restCaller.testQualify(name, imageIdentification.imagesIds.get(position),score);
            assertScore(name, imageIdentification.imagesIds.get(position),score, qualificationSession);
        }
        restCaller.testNextJob(name, null, null);
    }

    private long createQualification(String name1, String name2) {
        long qualificationSession = restCaller.joinQualificationSession(name1, null, LOCATION_CODE);
        restCaller.joinQualificationSession(name2, qualificationSession, LOCATION_CODE);
        return qualificationSession;
    }

    private void createQualifiers(String... names) {
        for(String name:names){
            restCaller.createUser(name, UserType.QUALIFIER);
        }
    }

    private int createScore() {
        int max = 5;
        int min = 1;
        return randomScore.nextInt(max - min + 1) + min;
    }

    private ImageIdentification sendImages(int amountOfImages) throws IOException, InterruptedException {
        List<String> identifications = new ArrayList<>();
        List<UUID> imagesIds=new ArrayList<>();
        for (int position = 0; position < amountOfImages; position++) {
            String identification = RandomStringUtils.randomAlphanumeric(6).toUpperCase();
            UUID imageId = restCaller.sendImage(position, LOCATION_CODE, identification);
            identifications.add(identification);
            imagesIds.add(imageId);
            Thread.sleep(1000L);
        }
        return new ImageIdentification(identifications, imagesIds);
    }

    private static class ImageIdentification {
        public final List<String> identifications;
        public final List<UUID> imagesIds;

        public ImageIdentification(List<String> identifications, List<UUID> imagesIds) {
            this.identifications = identifications;
            this.imagesIds = imagesIds;
        }
    }

    private void assertScore(String userName, UUID setCode, int score, long qualificationSession) {

        List<Integer> actualScore = jdbcTemplate.queryForList(
                "SELECT qs.SCORE from QUALIFIED_SCORE qs " +
                        "LEFT JOIN USER_QUALIFICATION_SESSION usq ON qs.USER_ID = usq.USER_ID AND qs.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                        "LEFT JOIN USER_LOCATION_QUALIFICATION_SESSION ulsq ON usq.USER_ID = usq.USER_ID AND ulsq.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                        "LEFT JOIN QUALIFICATION_SESSION qsession ON ulsq.QUALIFICATION_SESSION_ID = qsession.ID " +
                        "LEFT JOIN USER u ON u.ID = ulsq.USER_ID "+
                        "LEFT JOIN IMAGE_SET iset ON iset.ID = qs.IMAGE_SET_ID "+
                        "WHERE u.USER_NAME = '"+userName+"' AND iset.SET_CODE = '"+setCode.toString()+"' "+
                        "AND qsession.ID = "+qualificationSession, Integer.class);
        Assertions.assertNotNull(actualScore);
        if(actualScore.size()==1) {
            Assertions.assertEquals(score, actualScore.get(0));
        }else{
            List<QualifierEntity> qualifierEntities = jdbcTemplate.query(
                    "SELECT qs.* from QUALIFIED_SCORE qs " +
                            "LEFT JOIN USER_QUALIFICATION_SESSION usq ON qs.USER_ID = usq.USER_ID AND qs.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                            "LEFT JOIN USER_LOCATION_QUALIFICATION_SESSION ulsq ON usq.USER_ID = usq.USER_ID AND ulsq.QUALIFICATION_SESSION_ID = usq.QUALIFICATION_SESSION_ID " +
                            "LEFT JOIN QUALIFICATION_SESSION qsession ON ulsq.QUALIFICATION_SESSION_ID = qsession.ID " +
                            "LEFT JOIN USER u ON u.ID = ulsq.USER_ID " +
                            "LEFT JOIN IMAGE_SET iset ON iset.ID = qs.IMAGE_SET_ID " +
                            "WHERE u.USER_NAME = '" + userName + "' AND iset.SET_CODE = '" + setCode.toString() + "' " +
                            "AND qsession.ID = " + qualificationSession, new BeanPropertyRowMapper<>(QualifierEntity.class));
            qualifierEntities.size();
        }
    }


}
