package com.mobilebcs.controller.prediction;

import com.mobilebcs.domain.predictions.CurrentQualificationSearch;
import com.mobilebcs.domain.predictions.EndedQualificationSessionPredictionSearch;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/prediction")
public class PredictionController {


    private final CurrentQualificationSearch currentQualificationSearch;
    private final EndedQualificationSessionPredictionSearch endedQualificationSessionPredictionSearch;

    public PredictionController(CurrentQualificationSearch currentQualificationSearch,
                                EndedQualificationSessionPredictionSearch endedQualificationSessionPredictionSearch) {
        this.currentQualificationSearch = currentQualificationSearch;
        this.endedQualificationSessionPredictionSearch = endedQualificationSessionPredictionSearch;
    }

    @GetMapping(value = "/{qualificationSessionId}",produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<QualifierSessionPredictionResponse> get(@PathVariable("qualificationSessionId") Long qualificationSessionId ){
        return ResponseEntity.ok(endedQualificationSessionPredictionSearch.findSpecificQualificationSession(qualificationSessionId));
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<QualifierSessionsPredictionResponse> search(PredictionCriteria predictionCriteria) {
        System.out.println(predictionCriteria.toString());
        QualifierSessionPredictionResponse response=null;
        switch (predictionCriteria.getSearchType()) {
            case LAST_QUALIFICATION: response =
                endedQualificationSessionPredictionSearch.findLast(predictionCriteria.getLocation());
                break;
            case CURRENT_QUALIFICATION:
                response = currentQualificationSearch.find(predictionCriteria.getLocation());
                break;
        }
        if (response==null || response.getCaravanSize()==null || response.getCaravanSize()==0) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.ok(new QualifierSessionsPredictionResponse(List.of(response)));
        }
    }

}
