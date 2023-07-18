package com.mobilebcs.domain.predictions;

import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.ScoreResponse;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class CurrentQualificationSearch {


    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    private static final String SELECT_CURRENT_QUALIFICATION="SELECT lqs.QUALIFICATION_SESSION_ID FROM LOCATION_QUALIFICATION_SESSION lqs LEFT JOIN LOCATION l ON lqs.LOCATION_ID = l.ID WHERE l.CODE = :location";

    private static final String SELECT_IMAGES_BY_LOCATION_CODE = "SELECT ims.ID FROM IMAGE_SET ims LEFT JOIN IMAGE_SET_LOCATION isl ON ims.ID = isl.IMAGE_SET_ID LEFT JOIN LOCATION l ON isl.LOCATION_ID = l.ID WHERE l.CODE = :location";
    private static final String SELECT_PREDICTED_SCORE_WITH_LOCATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID IS NULL AND IMAGE_SET_ID IN (" +
        SELECT_IMAGES_BY_LOCATION_CODE + ")";

    private static final String SELECT_PREDICTED_SCORE_WITH_QUALIFICATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID = :qualificationSessionId";

    private static final String SELECT_CARAVAN_SIZE="SELECT COUNT(1) FROM IMAGE_SET_LOCATION isl LEFT JOIN LOCATION l ON isl.LOCATION_ID = l.ID WHERE l.CODE = :location";
    public CurrentQualificationSearch(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public QualifierSessionPredictionResponse find(String location) {
        LocalDateTime endDate=null;
        Long currentQualificationSessionId = findCurrentQualificationSessionId(location);

        QualifierSessionPredictionResponse qualifierSessionPredictionResponse=null;
        List<Double> scores=new ArrayList<>();
        if(currentQualificationSessionId==null) {
            scores = getScoreByLocation(location);
        }else{
            scores = getScoreByQualificationSession(currentQualificationSessionId);

        }
        System.out.println("score size is "+ Optional.ofNullable(scores).map(List::size).orElse(0));
        Integer caravanSize=getCaravanSize(location);
        if(caravanSize!=null && caravanSize>0){
            qualifierSessionPredictionResponse=createResponse(scores,endDate,currentQualificationSessionId,caravanSize);
        }
        return qualifierSessionPredictionResponse;
    }

    private Integer getCaravanSize(Object locationCode) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", locationCode);
        return namedParameterJdbcTemplate.queryForObject(SELECT_CARAVAN_SIZE, paramMap, Integer.class);
    }

    private List<Double> getScoreByQualificationSession(Long currentQualificationSessionId) {
        List<Double> scores;
        System.out.println("qualification session is " + currentQualificationSessionId);
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", currentQualificationSessionId);
        scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_QUALIFICATION, paramMap, Double.class);
        return scores;
    }

    private List<Double> getScoreByLocation(String location) {
        List<Double> scores;
        System.out.println("qualification session is null");
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_LOCATION, paramMap, Double.class);
        return scores;
    }

    private QualifierSessionPredictionResponse createResponse(List<Double> scores, LocalDateTime endDate, Long currentQualificationSessionId, Integer caravanSize) {
        List<ScoreResponse> scoreResponse = scores.stream().map(ScoreResponse::new).collect(Collectors.toList());
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = new QualifierSessionPredictionResponse();
        qualifierSessionPredictionResponse.setScores(scoreResponse);
        qualifierSessionPredictionResponse.setSessionEndDate(endDate);
        qualifierSessionPredictionResponse.setQualificationSession(currentQualificationSessionId);
        qualifierSessionPredictionResponse.setCaravanSize(caravanSize);
        return qualifierSessionPredictionResponse;
    }

    private Long findCurrentQualificationSessionId(String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        Long qualificationSessionId=null;
        try {
            qualificationSessionId = namedParameterJdbcTemplate.queryForObject(SELECT_CURRENT_QUALIFICATION, paramMap, Long.class);
        }catch (EmptyResultDataAccessException exception){

        }
        return qualificationSessionId;
    }


}
