package com.mobilebcs.controller.qualifier;


import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.qualifier.JobConsumerService;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.exception.UserNonexistentException;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.jms.JMSException;

@RestController
@RequestMapping("/qualifier")
public class QualifierController {


    private final JobConsumerService jobConsumerService;

    public QualifierController(JobConsumerService jobConsumerService) {
        this.jobConsumerService = jobConsumerService;
    }

    @GetMapping(value = "/{name}/next-animal", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<NextCaravanMessage> getJob(@PathVariable("name") String identificationName) throws UserNonexistentException, InvalidOperationException, JMSException {
        NextCaravanMessage job = jobConsumerService.nextJob(identificationName);
        ResponseEntity<NextCaravanMessage> responseEntity;
        if(job!=null){
            System.out.println("Next animal for "+identificationName+" is "+job.getSetId());
            responseEntity= ResponseEntity.ok(job);
        }else {
            System.out.println("Next animal for "+identificationName+" is empty");
            responseEntity=ResponseEntity.noContent().build();
        }
        return responseEntity;
    }
    
}
