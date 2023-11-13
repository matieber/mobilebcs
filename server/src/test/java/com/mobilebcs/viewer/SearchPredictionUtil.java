package com.mobilebcs.viewer;

import com.mobilebcs.RestCaller;
import com.mobilebcs.controller.prediction.QualifierSessionAverageResponse;
import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.QualifierSessionsAverageResponse;
import com.mobilebcs.controller.prediction.ScoreResponse;
import com.mobilebcs.controller.prediction.SearchType;
import java.time.LocalDateTime;
import java.util.List;

import org.junit.jupiter.api.Assertions;
import org.springframework.util.CollectionUtils;


public class SearchPredictionUtil {


    private final RestCaller restCaller;

    public SearchPredictionUtil(RestCaller restCaller){
        this.restCaller=restCaller;
    }

    public void testSearchPredictionNoContent(SearchType searchType){
        restCaller.searchPredictionNoContent(searchType);
        restCaller.searchDispersionNoContent(10);
    }
    public void testSearchDiagram(SearchType searchType,int expected){
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = restCaller.searchPrediction(searchType);

        Assertions.assertNull(qualifierSessionPredictionResponse.getQualificationSession());

        Assertions.assertEquals(expected,  qualifierSessionPredictionResponse.getScores().size());
        if(searchType.equals(SearchType.LAST_QUALIFICATION)) {
            searchDispersion(qualifierSessionPredictionResponse.getScores(), qualifierSessionPredictionResponse.getQualificationSession());
        }
    }

    public void testSearchDiagram(SearchType searchType,int expected, Long qualificationSession, LocalDateTime beforeStartDate, LocalDateTime afterEndDate){
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = restCaller.searchPrediction(searchType);

        Assertions.assertEquals(qualificationSession,qualifierSessionPredictionResponse.getQualificationSession());
        Assertions.assertEquals(expected,  qualifierSessionPredictionResponse.getScores().size());
        LocalDateTime sessionStartDate = qualifierSessionPredictionResponse.getSessionStartDate();
        Assertions.assertNotNull(sessionStartDate);
        Assertions.assertTrue(beforeStartDate.isBefore(sessionStartDate));
        LocalDateTime actualSessionEndDate = qualifierSessionPredictionResponse.getSessionEndDate();
        if(afterEndDate!=null) {
            Assertions.assertNotNull(actualSessionEndDate);
            Assertions.assertTrue(beforeStartDate.isBefore(actualSessionEndDate), beforeStartDate.toString() + " tiene que ser menor a " + actualSessionEndDate);
            Assertions.assertTrue(afterEndDate.isAfter(actualSessionEndDate));
        }else{
            Assertions.assertNull(actualSessionEndDate);
        }

        QualifierSessionPredictionResponse qualifierSessionPredictionResponseById =
                restCaller.searchPrediction(qualifierSessionPredictionResponse.getQualificationSession());
        assertQualificationSessionPredictionResponse(qualifierSessionPredictionResponse,qualifierSessionPredictionResponseById);
        if(searchType.equals(SearchType.LAST_QUALIFICATION)) {
            searchDispersion( qualifierSessionPredictionResponse.getScores(), qualifierSessionPredictionResponse.getQualificationSession());
        }
    }

    private void searchDispersion(List<ScoreResponse> lastScores, Long lastQualificationSession) {

        QualifierSessionsAverageResponse qualifierSessionsAverageResponse = restCaller.searchDispersion(10);
        if(!CollectionUtils.isEmpty(lastScores)&&lastScores.size()>1) {

            final double average = lastScores.stream().map(ScoreResponse::getValue).reduce(0.0, Double::sum) / lastScores.size();

            double variance = lastScores.stream().map(ScoreResponse::getValue).map(score->score-average).map(value->Math.pow(value,2)).reduce(0.0,Double::sum)/(lastScores.size());
            double standardDeviation = Math.sqrt(variance);
            QualifierSessionAverageResponse last = qualifierSessionsAverageResponse.getValues().stream().filter(q -> q.getQualificationSession().equals(lastQualificationSession)).findAny().orElse(null);
            Assertions.assertNotNull(last);
            Assertions.assertEquals(average,last.getAverage(),0.0001);
            Assertions.assertEquals(standardDeviation,last.getStandardDeviation(),0.0001);
        }


    }

    private static void assertQualificationSessionPredictionResponse(QualifierSessionPredictionResponse expected, QualifierSessionPredictionResponse actual) {
        Assertions.assertNotNull(actual);
        Assertions.assertEquals(expected.getQualificationSession(), actual.getQualificationSession());
        Assertions.assertEquals(expected.getCaravanSize(), actual.getCaravanSize());
        Assertions.assertEquals(expected.getScores().size(), actual.getScores().size());
        Assertions.assertEquals(expected.getSessionStartDate(), actual.getSessionStartDate());
        Assertions.assertEquals(expected.getSessionEndDate(), actual.getSessionEndDate());
        List<ScoreResponse> scores = expected.getScores();
        List<ScoreResponse> scores2 = actual.getScores();
        for (int i = 0; i < scores.size(); i++) {
            ScoreResponse scoreResponse = scores.get(i);
            ScoreResponse scoreResponse2 = scores2.get(i);
            Assertions.assertEquals(scoreResponse.getValue(),scoreResponse2.getValue());

        }
    }




}
