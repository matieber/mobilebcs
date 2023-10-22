package com.mobilebcs;

import com.mobilebcs.controller.images.CaravanImage;
import com.mobilebcs.controller.images.CaravanRequest;
import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.QualifierSessionsPredictionResponse;
import com.mobilebcs.controller.prediction.SearchType;
import com.mobilebcs.controller.qualifications.QualificationsResponse;
import com.mobilebcs.controller.qualifier.QualificationRequest;
import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.images.ImageEncoder;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Assertions;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.util.CollectionUtils;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.*;


public class RestCaller {

    private static final String IMAGE_NAME = "primer-plano-lateral-vaca-raza-hereford";
    private static final String IMAGE_EXTENSION = "png";


    private RestTemplate restTemplate;
    private NamedParameterJdbcTemplate jdbcTemplate;

    public RestCaller(int port) {
        restTemplate = new RestTemplateBuilder().rootUri("http://localhost:" + port).build();
    }

    public UUID sendImage(int position, String locationCode, String caravanIdentification) throws IOException {

        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list = new ArrayList<>();
        String imageName = IMAGE_NAME;
        byte[] content = ImageEncoder.getImage(imageName, IMAGE_EXTENSION);
        list.add(new CaravanImage(content, IMAGE_NAME+ "." + IMAGE_EXTENSION));

        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, caravanIdentification, list, setCode), Void.class);
        Assertions.assertEquals(204, response.getStatusCodeValue());
        return setCode;


    }

    public UUID sendRealImage(int position, String locationCode, String name) throws IOException {

        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list = new ArrayList<>();
        String imageName = "cow_images."+position;
        byte[] content = ImageEncoder.getImage(imageName, IMAGE_EXTENSION);
        list.add(new CaravanImage(content, IMAGE_NAME+ "." + IMAGE_EXTENSION));

        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, name, list, setCode), Void.class);
        Assertions.assertEquals(204, response.getStatusCodeValue());
        return setCode;


    }


    void testNextJob(String name, Integer position, String identification) {
        ResponseEntity<NextCaravanMessage> entity = restTemplate.getForEntity("/qualifier/" + name + "/next-animal", NextCaravanMessage.class);


        if (position != null) {
            Assertions.assertEquals(200, entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNotNull(nextCaravanMessage);
            Assertions.assertEquals(position, nextCaravanMessage.getPosition());
            Assertions.assertEquals(identification,nextCaravanMessage.getIdentification());
        } else {
            Assertions.assertEquals(204, entity.getStatusCodeValue());
            NextCaravanMessage nextCaravanMessage = entity.getBody();
            Assertions.assertNull(nextCaravanMessage);
        }
    }

    public long joinQualificationSession(String name, Long qualificationSession, String locationCode) {
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


    public void endSession(String locationCode) {
        ResponseEntity<Void> endResponse = restTemplate.exchange("/location/{locationCode}/qualificationSession", HttpMethod.DELETE, new HttpEntity<>(null, null), Void.class, locationCode);
        Assertions.assertEquals(204, endResponse.getStatusCodeValue());
    }

    public void createUser(String userName, UserType qualifier) {
        UserRequest userRequest = new UserRequest(userName, qualifier.name());
        ResponseEntity<Void> creationResponse = restTemplate.exchange("/user", HttpMethod.POST, new HttpEntity<>(userRequest, null), Void.class);
        Assertions.assertEquals(201, creationResponse.getStatusCodeValue());
    }

    public QualifierSessionPredictionResponse searchPrediction(Long qualificationSessionId) {
        ResponseEntity<QualifierSessionPredictionResponse> forEntity =
                restTemplate.exchange("/prediction/"+qualificationSessionId,HttpMethod.GET,HttpEntity.EMPTY, QualifierSessionPredictionResponse.class);
        Assertions.assertEquals(HttpStatus.OK,forEntity.getStatusCode());
        Assertions.assertNotNull(forEntity.getBody());
        return forEntity.getBody();
    }

    public QualifierSessionPredictionResponse searchPrediction(SearchType searchType) {
        ResponseEntity<QualifierSessionsPredictionResponse> forEntity =
            restTemplate.exchange("/prediction?onlyLastOne=true&location=DEFAULT&searchType="+searchType.name(),HttpMethod.GET,HttpEntity.EMPTY, QualifierSessionsPredictionResponse.class);
        Assertions.assertEquals(HttpStatus.OK,forEntity.getStatusCode());
        Assertions.assertNotNull(forEntity.getBody());
        Assertions.assertNotNull(forEntity.getBody().getValues());
        Assertions.assertEquals(1,forEntity.getBody().getValues().size());
        return forEntity.getBody().getValues().get(0);
    }

    public void searchPredictionNoContent(SearchType searchType) {
        ResponseEntity<QualifierSessionsPredictionResponse> forEntity =
            restTemplate.exchange("/prediction?onlyLastOne=true&location=DEFAULT&searchType="+searchType.name(),HttpMethod.GET,HttpEntity.EMPTY, QualifierSessionsPredictionResponse.class);
        Assertions.assertEquals(HttpStatus.NO_CONTENT,forEntity.getStatusCode());
    }

    public QualificationsResponse getQualifications(String location) {
        ResponseEntity<QualificationsResponse> forEntity =
                restTemplate.exchange("/qualifications/"+location,HttpMethod.GET,HttpEntity.EMPTY, QualificationsResponse.class);
        Assertions.assertTrue(forEntity.getStatusCode().is2xxSuccessful());
        QualificationsResponse body = forEntity.getBody();
        if(body!=null && !CollectionUtils.isEmpty(body.getQualificationResponse())){
            int distinctSize = body.getQualificationResponse().stream().distinct().collect(Collectors.toList()).size();
            Assertions.assertEquals(body.getQualificationResponse().size(),distinctSize);
        }
        return body;
    }

    void testQualify(String userName, UUID setId, int score){
        ResponseEntity<Void> response = restTemplate.exchange("/qualifier/" + userName + "/setCode/" + setId, HttpMethod.PUT, new HttpEntity<>(new QualificationRequest(score), new LinkedMultiValueMap<>()), Void.class);
        Assertions.assertEquals(204,response.getStatusCodeValue());

    }
}
