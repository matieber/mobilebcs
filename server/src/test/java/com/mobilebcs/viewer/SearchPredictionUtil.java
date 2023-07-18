package com.mobilebcs.viewer;

import com.mobilebcs.RestCaller;
import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.SearchType;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Assertions;


public class SearchPredictionUtil {


    private final RestCaller restCaller;

    public SearchPredictionUtil(RestCaller restCaller){
        this.restCaller=restCaller;
    }

    public void testSearchPredictionNoContent(SearchType searchType){
        restCaller.searchPredictionNoContent(searchType);
    }
    public void testSearchDiagram(SearchType searchType,int expected){
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = restCaller.searchPrediction(searchType);

        Assertions.assertNull(qualifierSessionPredictionResponse.getQualificationSession());

        Assertions.assertEquals(expected,  qualifierSessionPredictionResponse.getScores().size());
    }

    public void testSearchDiagram(SearchType searchType,int expected, Long qualificationSession, LocalDateTime beforeStartDate, LocalDateTime afterEndDate){
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = restCaller.searchPrediction(searchType);

        Assertions.assertEquals(qualificationSession,qualifierSessionPredictionResponse.getQualificationSession());
        Assertions.assertEquals(expected,  qualifierSessionPredictionResponse.getScores().size());
//        LocalDateTime sessionStartDate = qualifierSessionPredictionResponse.getSessionStartDate();
//        Assertions.assertNotNull(sessionStartDate);
//        Assertions.assertTrue(beforeStartDate.isBefore(sessionStartDate));
        LocalDateTime actualSessionEndDate = qualifierSessionPredictionResponse.getSessionEndDate();
        if(afterEndDate!=null) {
            Assertions.assertNotNull(actualSessionEndDate);
            Assertions.assertTrue(beforeStartDate.isBefore(actualSessionEndDate), beforeStartDate.toString() + " tiene que ser menor a " + actualSessionEndDate);
            Assertions.assertTrue(afterEndDate.isAfter(actualSessionEndDate));
        }else{
            Assertions.assertNull(actualSessionEndDate);
        }
    }







}
