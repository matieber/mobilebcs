package com.mobilebcs.controller.images;

import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.images.ImagesService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.sql.SQLException;

@RestController
@RequestMapping("/location")
public class ImagesController {

    private final ImagesService imagesService;

    public ImagesController(ImagesService imagesService) {
        this.imagesService = imagesService;
    }

    @PostMapping(value = "/{location-code}/caravan",consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> saveCaravan(@PathVariable("location-code") String locationCode, @RequestBody CaravanRequest caravanRequest) throws IOException, SQLException, InvalidLocalizationException {
        imagesService.save(locationCode,caravanRequest);
        return ResponseEntity.noContent().build();
    }
}
