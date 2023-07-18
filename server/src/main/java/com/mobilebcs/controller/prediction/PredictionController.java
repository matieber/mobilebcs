package com.mobilebcs.controller.prediction;

import com.mobilebcs.domain.predictions.CurrentQualificationSearch;
import com.mobilebcs.domain.predictions.LastQualificationSearch;
import com.mobilebcs.domain.predictions.PredictionSearchService;
import java.util.List;
import jdk.jshell.spi.ExecutionControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/prediction")
public class PredictionController {


    private final CurrentQualificationSearch currentQualificationSearch;
    private final LastQualificationSearch lastQualificationSearch;

    public PredictionController(CurrentQualificationSearch currentQualificationSearch,
                                LastQualificationSearch lastQualificationSearch) {
        this.currentQualificationSearch = currentQualificationSearch;
        this.lastQualificationSearch = lastQualificationSearch;
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<QualifierSessionsPredictionResponse> search(PredictionCriteria predictionCriteria) {
        System.out.println(predictionCriteria.toString());
        QualifierSessionPredictionResponse response=null;
        switch (predictionCriteria.getSearchType()) {
            case LAST_QUALIFICATION: response =
                lastQualificationSearch.find(predictionCriteria.getLocation());
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
