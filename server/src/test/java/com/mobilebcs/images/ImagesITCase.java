package com.mobilebcs.images;

import com.mobilebcs.AbstractITCase;
import com.mobilebcs.ServerApp;
import com.mobilebcs.controller.images.CaravanImage;
import com.mobilebcs.controller.images.CaravanRequest;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import org.testcontainers.shaded.org.apache.commons.lang.RandomStringUtils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ImagesITCase extends AbstractITCase {

    @Value("${images.path}")
    private String imagePath;
    public static final String IMAGE_NAME = "primer-plano-lateral-vaca-raza-hereford";
    public static final String IMAGE_EXTENSION = "png";
    public static final String SELECT_PATH = "SELECT i.PATH, iset.IDENTIFICATION FROM " +
            "IMAGE i INNER JOIN IMAGE_SET iset ON iset.ID = i.IMAGE_SET_ID INNER JOIN " +
            "IMAGE_SET_LOCATION isl ON iset.ID = isl.IMAGE_SET_ID INNER JOIN " +
            "LOCATION l ON l.ID = isl.LOCATION_ID " +
            "WHERE l.CODE = ? AND iset.SET_CODE = ? AND isl.`POSITION` = ?;";
    @LocalServerPort
    private Long randomServerPort;

    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private NamedParameterJdbcTemplate jdbcTemplate;

    @BeforeEach
    public void init() throws IOException {
        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));

    }

    @Test
    public void testSaveImages() throws IOException {

        String locationCode = "DEFAULT";
        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list = new ArrayList<>();
        byte[] content = ImageEncoder.getImage(IMAGE_NAME, IMAGE_EXTENSION);
        list.add(new CaravanImage(content, IMAGE_NAME + "." + IMAGE_EXTENSION));
        int position = 1;


        String identification = RandomStringUtils.randomAlphanumeric(6).toUpperCase();
        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, identification, list, setCode), Void.class);
        Assertions.assertEquals(204, response.getStatusCodeValue());

        ImageEntity imageEntity = jdbcTemplate.getJdbcTemplate().queryForObject(SELECT_PATH, (rs, rowNum) -> {
            String path = rs.getString("PATH");
            String identification1 = rs.getString("IDENTIFICATION");
            return new ImageEntity(path, identification1);
        }, locationCode, setCode.toString(),position);
        assertNotNull(imageEntity);
        assertNotNull(imageEntity.getIdentification());
        assertEquals(identification,imageEntity.getIdentification());
        byte[] actualBytes = FileUtils.readFileToByteArray(new File(Paths.get(imagePath, imageEntity.getPath()).toString()));
        Assertions.assertArrayEquals(content, actualBytes);



    }

    @Test
    public void testSaveImagesWithInvalidLocationCode() throws IOException {

        String locationCode = "INVALID";
        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list = new ArrayList<>();
        byte[] content = ImageEncoder.getImage(IMAGE_NAME, IMAGE_EXTENSION);
        list.add(new CaravanImage(content, IMAGE_NAME + "." + IMAGE_EXTENSION));
        int position = 1;


        String name = RandomStringUtils.randomAlphanumeric(6).toUpperCase();
        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, name, list, setCode), Void.class);
        Assertions.assertEquals(404, response.getStatusCodeValue());


    }

    @AfterEach
    public void clean() {
        Map<String, Object> paramMap = new HashMap<>();

        jdbcTemplate.update("TRUNCATE TABLE IMAGE_SET_LOCATION", paramMap);
    }


}
