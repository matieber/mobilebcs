package com.mobilebcs.controller.calificator;


import com.mobilebcs.configuration.PublisherFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.Message;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/calificator")
public class CalificatorController {

    @Autowired
    private PublisherFactory publisherFactory;

    @GetMapping(value = "/{name}/next-animal", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> getImage(@PathVariable("name") String identificationName) {
        return Flux.from(publisherFactory.getPublisherBy(identificationName))
                .map(Message::getPayload);
    }
    
}
