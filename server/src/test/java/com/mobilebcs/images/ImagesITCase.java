package com.mobilebcs.images;

import com.mobilebcs.AbstractITCase;
import com.mobilebcs.ServerApp;
import com.mobilebcs.controller.images.CaravanImage;
import com.mobilebcs.controller.images.CaravanRequest;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;


import static org.junit.jupiter.api.Assertions.assertNotNull;

@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ImagesITCase extends AbstractITCase {

    @Value("${images.path}")
    private String imagePath;
    public static final String IMAGE_NAME = "primer-plano-lateral-vaca-raza-hereford";
    public static final String IMAGE_EXTENSION = "jpg";
    public static final String SELECT_PATH = "SELECT i.PATH FROM " +
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

        String locationCode="DEFAULT";
        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list=new ArrayList<>();
        byte[] content = getImage();
        list.add(new CaravanImage(content,IMAGE_NAME+"."+ IMAGE_EXTENSION));
        int position = 1;


        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, list, setCode), Void.class);
        Assertions.assertEquals(204,response.getStatusCodeValue());

        String path = jdbcTemplate.getJdbcTemplate().queryForObject(SELECT_PATH, String.class,locationCode,setCode.toString(),position);
        assertNotNull(path);
        byte[] actualBytes = FileUtils.readFileToByteArray(new File(Paths.get(imagePath,path).toString()));
        Assertions.assertArrayEquals(content,actualBytes);

    }

    @Test
    public void testSaveImagesWithInvalidLocationCode() throws IOException {

        String locationCode="INVALID";
        UUID setCode = UUID.randomUUID();
        List<CaravanImage> list=new ArrayList<>();
        byte[] content = getImage();
        list.add(new CaravanImage(content,IMAGE_NAME+"."+ IMAGE_EXTENSION));
        int position = 1;


        ResponseEntity<Void> response = restTemplate.postForEntity("/location/" + locationCode + "/caravan", new CaravanRequest(position, list, setCode), Void.class);
        Assertions.assertEquals(400,response.getStatusCodeValue());


    }

    public byte[] getImage() throws IOException {
        String resourceName= "images/" + IMAGE_NAME + "." + IMAGE_EXTENSION;

        ClassLoader classLoader = this.getClass().getClassLoader();

        URL resource = classLoader.getResource(resourceName);
        BufferedImage img = ImageIO.read(resource);
        return encode(img, IMAGE_EXTENSION);
    }

    public static byte[] encode(BufferedImage image, String extension) throws IOException {

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ImageIO.write(image, extension, bos);
        byte[] imageBytes = bos.toByteArray();
        bos.close();
        return imageBytes;

    }
}
