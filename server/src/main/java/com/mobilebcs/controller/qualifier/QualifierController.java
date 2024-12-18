package com.mobilebcs.controller.qualifier;


import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.qualifier.JobConsumerService;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.qualifier.QualifierService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.jms.JMSException;
import java.sql.SQLException;
import java.util.UUID;

@RestController
@RequestMapping("/qualifier")
public class QualifierController {


    private final JobConsumerService jobConsumerService;

    private final QualifierService qualifierService;


    public QualifierController(JobConsumerService jobConsumerService, QualifierService qualifierService) {
        this.jobConsumerService = jobConsumerService;
        this.qualifierService = qualifierService;
    }

    @GetMapping(value = "/{name}/next-animal", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<NextCaravanMessage> getJob(@PathVariable("name") String identificationName) throws UserNonexistentException, InvalidOperationException, JMSException {
        NextCaravanMessage job = jobConsumerService.nextJob(identificationName);
        ResponseEntity<NextCaravanMessage> responseEntity;
        if(job!=null){
            responseEntity= ResponseEntity.ok(job);
        }else {
            responseEntity=ResponseEntity.noContent().build();
        }
        return responseEntity;
    }


    @PutMapping(value = "/{name}/setCode/{setCode}")
    public ResponseEntity<Void> qualify(@PathVariable("name") String identificationName, @PathVariable("setCode") UUID setCode,@RequestBody QualificationRequest qualificationRequest) throws InvalidOperationException, UserNonexistentException, SQLException {
        System.out.println("score "+qualificationRequest.getScore());
        qualifierService.qualify(identificationName,setCode,qualificationRequest.getScore());
        return ResponseEntity.noContent().build();
    }
    
}
