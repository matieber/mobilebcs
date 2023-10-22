package com.mobilebcs.controller.qualifications;


import com.mobilebcs.domain.qualifications.QualificationRepository;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/qualifications")
public class QualificationController {

    private final QualificationRepository qualificationRepository;

    public QualificationController(QualificationRepository qualificationRepository) {
        this.qualificationRepository = qualificationRepository;
    }

    @GetMapping(value = "/{location}")
    public ResponseEntity<QualificationsResponse> getQualifications(@PathVariable("location") String location){
        List<Long> endedQualificationSessionIds = qualificationRepository.findEndedQualificationSessionIds(location);
        if(!CollectionUtils.isEmpty(endedQualificationSessionIds)){
            List<QualificationResponse> list = endedQualificationSessionIds.stream().map(QualificationResponse::new).collect(Collectors.toList());
            return ResponseEntity.ok(new QualificationsResponse(list));
        }else{
            return ResponseEntity.noContent().build();
        }
    }
}
